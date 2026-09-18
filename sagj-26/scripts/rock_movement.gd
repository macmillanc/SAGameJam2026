extends CharacterBody2D
@export var stage_textures: Array[Texture2D] = []
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

@export var speed: float = 300.0

## Base jump velocity at Stage 0 (negative values move UP in Godot 2D).
@export var base_jump_velocity: float = -300.0

## Controls how fast the rock reaches top speed and slows down.
@export var traction: float = 0.05

## How far down the rock can fall before dying (in pixels).
@export var fall_limit: float = 1000.0

## The starting number of lives for the player.
@export var max_lives: int = 3

## Drag your GameOver.tscn scene file from the FileSystem dock into this slot in the Inspector!
@export_file("*.tscn") var game_over_scene: String

# Track current lives dynamically
var current_lives: int
var stage: int

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	current_lives = max_lives
	
	stage = 0
	
	# Set the initial sprite texture when spawning
	if stage_textures.size() > stage and stage_textures[stage]:
		sprite.texture = stage_textures[stage]
	
	# Set initial scale and collision size
	update_sprite_and_collision()

	Global.last_played_level = get_tree().current_scene.scene_file_path
	
	
	# SAVES THE CURRENT LEVEL: This grabs the file path of the current active level scene
	Global.last_played_level = get_tree().current_scene.scene_file_path


func _physics_process(delta: float) -> void:
	# Add the gravity if the character is not on the floor.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump directly using the Space key
	if Input.is_key_pressed(KEY_SPACE) and is_on_floor():
		# Smaller sizes jump higher (15% higher per stage shrunk)
		var jump_multiplier: float = pow(1.15, stage)
		velocity.y = base_jump_velocity * jump_multiplier

	# Check if the rock has fallen off the map
	if global_position.y > fall_limit:
		die_and_respawn()

	# Handle horizontal movement (using your traction system)
	var direction := Input.get_axis("left", "right")
	var target_velocity_x = direction * speed
	velocity.x = lerp(velocity.x, target_velocity_x, traction)
	
	# Move the character and process collisions
	move_and_slide()

	# Rotate sprite based on speed, direction, and current scale size
	if sprite and sprite.texture:
		var current_scale: float = pow(0.8, stage)
		var current_radius: float = (sprite.texture.get_width() / 2.0) * current_scale
		if current_radius > 0:
			# Rolling formula: angular velocity = linear velocity / radius
			sprite.rotation += (velocity.x / current_radius) * delta

func die_and_respawn() -> void:
	# Lose a life
	current_lives -= 1
	print("Lives remaining: ", current_lives)
	
	# Check if it's Game Over
	if current_lives <= 0:
		game_over()
		return # <-- MAKE SURE THIS RETURN IS HERE to stop the script instantly!
	
	# Reset rotation along with position
	if sprite:
		sprite.rotation = 0
	global_position = Vector2(0, 0)
	velocity = Vector2.ZERO


func game_over() -> void:
	# Check if you remembered to assign the Game Over scene file path in the Inspector
	if game_over_scene != "":
		get_tree().change_scene_to_file(game_over_scene)
	else:
		# Safety fallback in case the scene isn't created or assigned yet
		get_tree().reload_current_scene() 

var changing_season = false

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_I:
			if not changing_season:
				change_season()


func change_season():
	changing_season = true

	var target_season = (Global.season + 1) % 4

	for i in range(12):
		Global.season = (Global.season + 1) % 4
		get_tree().call_group("season_objects", "update_grass")
		await get_tree().create_timer(0.075).timeout

	Global.season = target_season
	get_tree().call_group("season_objects", "update_grass")
	changing_season = false
	
	#Update rock sprite
	
	stage += 1
	if stage >= 5:
		game_over()
		return # <-- MAKE SURE THIS RETURN IS HERE to stop the script instantly!
	
	if stage_textures.size() > stage and stage_textures[stage]:
		sprite.texture = stage_textures[stage]
	
	update_sprite_and_collision()


func update_sprite_and_collision() -> void:
	# Calculates scale: 100% at stage 0, shrinking 20% each stage (1.0 -> 0.8 -> 0.64 -> 0.512 ...)
	var current_scale: float = pow(0.8, stage)
	
	if sprite:
		sprite.scale = Vector2(current_scale, current_scale)
		
	if collision_shape and collision_shape.shape is CircleShape2D and sprite and sprite.texture:
		collision_shape.shape = collision_shape.shape.duplicate()
		var base_radius: float = sprite.texture.get_width() / 2.0
		collision_shape.shape.radius = base_radius * current_scale
