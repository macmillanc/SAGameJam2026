class_name Player
extends CharacterBody2D

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
@export var decel: float = 1200.0
@export var base_jump_velocity: float = -350.0
@export var fall_limit: float = 1000.0
@export var max_lives: int = 3
@export_file("*.tscn") var game_over_scene: String

var current_lives: int
var stage: int = 0
var changing_season: bool = false
var is_slowed: bool = false
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

var hit_timer: float = 0.0
var spin_direction: float = 1.0


func _ready() -> void:
	current_lives = max_lives
	if stage_textures.size() > stage and stage_textures[stage]:
		sprite.texture = stage_textures[stage]
	update_sprite_and_collision()
	Global.last_played_level = get_tree().current_scene.scene_file_path


func _physics_process(delta: float) -> void:
	if hit_timer > 0.0:
		hit_timer -= delta

	state_machine.physics_process(delta)

	if global_position.y > fall_limit:
		die_and_respawn()

	if not is_inside_tree():
		return

	# Capture velocity BEFORE move_and_slide zeroes it out on collision
	var pre_collision_velocity: Vector2 = velocity

	move_and_slide()

	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		if collider is Crate:
			var normal = collision.get_normal()
			var impact_speed: float = abs(pre_collision_velocity.dot(normal))

			# Ignore minor brushes or slides along surfaces
			if impact_speed < 10.0:
				continue

			# Prevent rapid bounce loops if trapped against geometry
			if hit_timer > 0.0:
				velocity = velocity * 0.5
				break

			hit_timer = hit_cooldown

			# Force scale decreases as stage increases (Rock gets smaller / lighter)
			var force_multiplier: float = 1.0 - (clampf(stage, 0, 4) * 0.2)
			var effective_impact_force: float = impact_speed * force_multiplier

			# Apply damage to crate
			collider.take_damage(effective_impact_force, crate_particle_scene)

			# Apply physical pushing impulse to the RigidBody crate
			collider.apply_central_impulse(-normal * push_force)

			# Trigger camera shake
			trigger_camera_shake(effective_impact_force)

			# Bounce calculation
			var bounced_vel = pre_collision_velocity.bounce(normal)
			velocity = bounced_vel.normalized() * min(bounced_vel.length() * bounce_force, speed)

			# Nudge player away from crate to avoid multi-frame collision overlap
			global_position += normal * 2.0

			spin_direction *= 1.0
			break

	# Enforce hard max speed cap
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
	if event.is_action_pressed("change_season") and not changing_season:
		change_season()

	if event.is_action_pressed("slow_time"):
		scale_time(2.0, 0.5)
	
	if event.is_action_pressed("speed_time"):
		scale_time(2.0, 2.0)

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta


func apply_horizontal_movement(direction: float, delta: float = -1.0) -> void:
	if hit_timer > 0.0:
		return

	if delta < 0.0:
		delta = get_physics_process_delta_time()

	var target_speed: float = direction * speed
	var rate: float = accel if direction != 0.0 else decel
	
	velocity.x = move_toward(velocity.x, target_speed, rate * delta)


func jump() -> void:
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
	await get_tree().create_timer(seconds, true, false, true).timeout
	Engine.time_scale = 1.0
	is_slowed = false


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
	if game_over_scene != "":
		get_tree().change_scene_to_file(game_over_scene)
	else:
		get_tree().reload_current_scene()


func change_season() -> void:
	changing_season = true
	var target_season = (Global.season + 1) % 4

	for i in range(12):
		Global.season = (Global.season + 1) % 4
		get_tree().call_group("season_objects", "update_grass")
		await get_tree().create_timer(0.075).timeout

	Global.season = target_season
	get_tree().call_group("season_objects", "update_grass")
	# Calls 'on_season_changed()' on every active Crate node in the scene tree
	get_tree().call_group("Crates", "on_season_changed")
	changing_season = false

	stage += 1
	if stage >= 5:
		game_over()
		return

	if stage_textures.size() > stage and stage_textures[stage]:
		sprite.texture = stage_textures[stage]
	update_sprite_and_collision()


func update_sprite_and_collision() -> void:
	var current_scale: float = pow(0.8, stage)

	if sprite:
		sprite.scale = Vector2(current_scale, current_scale)

	if collision_shape and collision_shape.shape is CircleShape2D and sprite and sprite.texture:
		collision_shape.shape = collision_shape.shape.duplicate()
		var base_radius: float = sprite.texture.get_width() / 2.0
		collision_shape.shape.radius = base_radius * current_scale
