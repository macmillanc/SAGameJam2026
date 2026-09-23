class_name Player
extends CharacterBody2D
@export var canvas_modulate: CanvasModulate
@export var bounce_force: float = 0.85    # Bouncing return multiplier
@export var hit_cooldown: float = 0.15   # Cooldown in seconds between crate hits
@export var push_force: float = 100.0    # Impulse force applied to push crates on roll

# Optional scene path for crate debris particle effect
@export var crate_particle_scene: PackedScene

@export var stage_textures: Array[Texture2D] = []
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var state_machine: StateMachine = $States
@onready var camera: Camera2D = $Camera2D

# --- Movement Physics ---
@export var speed: float = 400.0
@export var max_speed: float = 500.0     # Hard velocity cap
@export var accel: float = 900.0
@export var decel: float = 300.0
@export var base_jump_velocity: float = -350.0
@export var fall_limit: float = 500.0
@export var max_lives: int = 3
@export_file("*.tscn") var game_over_scene: String

var current_lives: int
var stage: int = 0
var is_slowed: bool = false
var is_blurred: bool = false             
var ghost_timer: float = 0.0     
var ghost_spawn_interval: float = 0.03
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

var hit_timer: float = 0.0
var spin_direction: float = 1.0

# --- Season Transition Variables ---
var changing_season: bool = false
var season_transition_progress: float = 0.0 # 0.0 to 1.0 progress tracking
var start_season: int = 0
var target_season: int = 0

# --- Level Label Node Reference ---
@onready var level_label: Label = $LevelLabel


func _ready() -> void:
	
	# Ensure Player is registered in the "player" group for background/cloud scripts
	if not is_in_group("player"):
		add_to_group("player")

	current_lives = max_lives
	if stage_textures.size() > stage and stage_textures[stage]:
		sprite.texture = stage_textures[stage]
	update_sprite_and_collision()
	Global.last_played_level = get_tree().current_scene.scene_file_path
	
	_setup_level_label()


func _setup_level_label() -> void:
	if not level_label:
		level_label = get_node_or_null("LevelLabel") as Label
		
	if not level_label:
		push_error("Player.gd: Could not find 'LevelLabel' child node in rock.tscn!")
		return

	# Prevent label from spinning with player's rotation
	level_label.top_level = true
	
	# Parse current level number from scene file name
	var current_scene_path: String = get_tree().current_scene.scene_file_path
	var file_name: String = current_scene_path.get_file()
	
	var RegExClass = RegEx.new()
	RegExClass.compile("\\d+")
	var match_result = RegExClass.search(file_name)
	
	var level_num: int = 1
	if match_result:
		level_num = match_result.get_string().to_int()
		
	# Lookup level name from Global
	var level_name: String = "Unknown Area"
	if "level_names" in Global and Global.level_names.has(level_num):
		level_name = Global.level_names[level_num]
		
	level_label.text = "Level %d - %s" % [level_num, level_name]
	
	# Visual Styling: Size 32, White Text, 4px Grey Outline, Shadow
	var settings = LabelSettings.new()
	settings.font_size = 32
	settings.font_color = Color.WHITE
	settings.outline_size = 4
	settings.outline_color = Color(0.4, 0.4, 0.4, 1.0)
	settings.shadow_size = 6
	settings.shadow_color = Color(0.0, 0.0, 0.0, 0.6)
	settings.shadow_offset = Vector2(3, 3)
	
	level_label.label_settings = settings
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	level_label.global_position = global_position + Vector2(-level_label.size.x / 2.0, -80.0)
	level_label.visible = true
	level_label.modulate.a = 1.0
	
	# Animate: Display 1.5s then fade over 1.0s
	var tween = create_tween()
	tween.tween_interval(1.5)
	tween.tween_property(level_label, "modulate:a", 0.0, 1.0)
	tween.tween_callback(func(): 
		if is_instance_valid(level_label):
			level_label.visible = false
	)


func _physics_process(delta: float) -> void:
	if hit_timer > 0.0:
		hit_timer -= delta

	state_machine.physics_process(delta)

	if global_position.y > fall_limit:
		die_and_respawn()

	if not is_inside_tree():
		return

	# Keep label centered directly above the player while active
	if is_instance_valid(level_label) and level_label.visible and level_label.modulate.a > 0:
		level_label.global_position = global_position + Vector2(-level_label.size.x / 2.0, -80.0)

	# Capture velocity BEFORE move_and_slide zeroes it out on collision
	var pre_collision_velocity: Vector2 = velocity

	move_and_slide()

	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		if collider is Crate:
			var normal = collision.get_normal()
			var impact_speed: float = abs(pre_collision_velocity.dot(normal))

			if impact_speed < 10.0:
				continue

			if hit_timer > 0.0:
				velocity = velocity * 0.5
				break

			hit_timer = hit_cooldown

			var force_multiplier: float = 1.0 - (clampf(stage, 0, 4) * 0.2)
			var effective_impact_force: float = impact_speed * force_multiplier

			collider.take_damage(effective_impact_force, crate_particle_scene)
			collider.apply_central_impulse(-normal * push_force)
			trigger_camera_shake(effective_impact_force)

			var bounced_vel = pre_collision_velocity.bounce(normal)
			velocity = bounced_vel.normalized() * min(bounced_vel.length() * bounce_force, speed)
			global_position += normal * 2.0
			spin_direction *= 1.0
			break

	if velocity.length() > max_speed:
		velocity = velocity.limit_length(max_speed)

	update_rolling_rotation(delta)


func trigger_camera_shake(impact_force: float) -> void:
	var target_cam = camera if camera else get_viewport().get_camera_2d()
	if target_cam == null:
		return

	var shake_intensity: float = clampf(impact_force / 50.0, 2.0, 12.0)
	var tween = create_tween()

	for i in range(4):
		var offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		tween.tween_property(target_cam, "offset", offset, 0.03)

	tween.tween_property(target_cam, "offset", Vector2.ZERO, 0.05)


func _input(event: InputEvent) -> void:
	# Ignore all new key presses during season transition
	if changing_season:
		return

	# 1. Trigger using Input Map action "change_season"
	if event.is_action_pressed("change_season"):
		start_season_change(2.0)

	# 2. Fallback direct key trigger (I key)
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_I:
			start_season_change(2.0)

	if event.is_action_pressed("slow_time"):
		scale_time(2.0, 0.5)
	
	if event.is_action_pressed("speed_time"):
		scale_time(2.0, 2.0)
	
	if event.is_action_pressed("escape"):
		SceneManager.go_to_map()


func start_season_change(duration: float = 2.0) -> void:
	if changing_season:
		return
		
	changing_season = true
	start_season = Global.season
	target_season = (Global.season + 1) % 4
	
	print("SEASON: Starting smooth transition from ", start_season, " to ", target_season)
	
	var elapsed: float = 0.0
	
	# Continuous progress loop over the specified duration
	while elapsed < duration:
		await get_tree().process_frame
		elapsed += get_process_delta_time()
		season_transition_progress = clampf(elapsed / duration, 0.0, 1.0)
	
	# Finalize season state
	Global.season = target_season
	season_transition_progress = 0.0
	changing_season = false
	
	# Advance stage growth
	stage += 1
	if stage >= 5:
		game_over()
		
		return

	if stage_textures.size() > stage and stage_textures[stage]:
		sprite.texture = stage_textures[stage]
	update_sprite_and_collision()

	# Notify active object groups
	get_tree().call_group("season_objects", "update_grass")
	get_tree().call_group("season_objects", "update_tree")
	get_tree().call_group("Crates", "on_season_changed")

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta


func apply_horizontal_movement(direction: float, delta: float = -1.0) -> void:
	if hit_timer > 0.0:
		return

	# Override input direction to 0 if changing season so player decelerates naturally
	if changing_season:
		direction = 0.0

	if delta < 0.0:
		delta = get_physics_process_delta_time()

	var target_speed: float = direction * speed
	var rate: float = accel if direction != 0.0 else decel
	
	velocity.x = move_toward(velocity.x, target_speed, rate * delta)


func jump() -> void:
	# Do not allow jumping while season is changing
	if changing_season:
		return

	var jump_multiplier: float = pow(1.15, stage)
	velocity.y = base_jump_velocity * jump_multiplier


func update_rolling_rotation(delta: float) -> void:
	if sprite and sprite.texture:
		var current_scale: float = pow(0.8, stage)
		var current_radius: float = (sprite.texture.get_width() / 2.0) * current_scale
		if current_radius > 0:
			sprite.rotation += (velocity.x / current_radius) * delta * spin_direction


func scale_time(seconds: float, percentage: float) -> void:
	if is_slowed:
		return
	is_slowed = true
	Engine.time_scale = percentage
	
	# Determine target color
	var target_color: Color = Color(1, 1, 1, 1)
	if percentage < 1.0:
		target_color = Color(0.6, 0.8, 1.0, 1.0) # Cool Blue (Slow)
	else:
		target_color = Color(1.0, 0.7, 0.6, 1.0) # Warm Red (Fast)
	
	# Smoothly fade into the color tint over 0.25 seconds
	if canvas_modulate:
		var tween = create_tween().set_ignore_time_scale(true)
		tween.tween_property(canvas_modulate, "color", target_color, 0.25)
	
	if percentage > 1.0:
		is_blurred = true
	
	await get_tree().create_timer(seconds, true, false, true).timeout
	
	Engine.time_scale = 1.0
	is_slowed = false
	is_blurred = false
	
	# Smoothly fade back to normal white
	if canvas_modulate:
		var reset_tween = create_tween().set_ignore_time_scale(true)
		reset_tween.tween_property(canvas_modulate, "color", Color(1, 1, 1, 1), 0.25)

func die_and_respawn() -> void:
	current_lives -= 1
	print("Lives remaining: ", current_lives)

	if current_lives <= 0:
		game_over()
		return

	if sprite:
		sprite.rotation = 0
	global_position = Vector2.ZERO
	velocity = Vector2.ZERO


func game_over() -> void:
	SceneManager.game_over(game_over_scene)

func update_sprite_and_collision() -> void:
	var current_scale: float = pow(0.8, stage)

	if sprite:
		sprite.scale = Vector2(current_scale, current_scale)

	if collision_shape and collision_shape.shape is CircleShape2D and sprite and sprite.texture:
		collision_shape.shape = collision_shape.shape.duplicate()
		var base_radius: float = sprite.texture.get_width() / 2.0
		collision_shape.shape.radius = base_radius * current_scale
