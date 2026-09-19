class_name Player
extends CharacterBody2D

@export var stage_textures: Array[Texture2D] = []
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var state_machine: StateMachine = $States

@export var speed: float = 300.0
@export var base_jump_velocity: float = -300.0
@export var traction: float = 0.05
@export var fall_limit: float = 1000.0
@export var max_lives: int = 3
@export_file("*.tscn") var game_over_scene: String

var current_lives: int
var stage: int = 0
var changing_season: bool = false
var is_slowed: bool = false
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")


func _ready() -> void:
	current_lives = max_lives
	
	if stage_textures.size() > stage and stage_textures[stage]:
		sprite.texture = stage_textures[stage]
	
	update_sprite_and_collision()
	Global.last_played_level = get_tree().current_scene.scene_file_path


func _physics_process(delta: float) -> void:
	# 1. Update the FSM logic first
	state_machine.physics_process(delta)
	
	# 2. Check fall boundary
	if global_position.y > fall_limit:
		die_and_respawn()

	# 3. Apply physical movement & sprite rotation
	if not is_inside_tree():
		return
	move_and_slide()
	update_rolling_rotation(delta)


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_I and not changing_season:
			change_season()
		if event.pressed and event.keycode == KEY_J:
			scale_time(2.0, 0.5);


func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta


func apply_horizontal_movement(direction: float) -> void:
	var target_velocity_x = direction * speed
	velocity.x = lerp(velocity.x, target_velocity_x, traction)


func jump() -> void:
	var jump_multiplier: float = pow(1.15, stage)
	velocity.y = base_jump_velocity * jump_multiplier


func update_rolling_rotation(delta: float) -> void:
	if sprite and sprite.texture:
		var current_scale: float = pow(0.8, stage)
		var current_radius: float = (sprite.texture.get_width() / 2.0) * current_scale
		if current_radius > 0:
			sprite.rotation += (velocity.x / current_radius) * delta


func scale_time(seconds : float, percentage : float) -> void:
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
