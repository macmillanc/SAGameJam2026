extends CharacterBody2D

@export var speed: float = 300.0

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

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	current_lives = max_lives
	
	# SAVES THE CURRENT LEVEL: This grabs the file path of the current active level scene
	Global.last_played_level = get_tree().current_scene.scene_file_path


func _physics_process(delta: float) -> void:
	# Add the gravity if the character is not on the floor.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Check if the rock has fallen off the map
	if global_position.y > fall_limit:
		die_and_respawn()

	# Handle horizontal movement (using your traction system)
	var direction := Input.get_axis("left", "right")
	var target_velocity_x = direction * speed
	velocity.x = lerp(velocity.x, target_velocity_x, traction)
	
	# Move the character and process collisions
	move_and_slide()

func die_and_respawn() -> void:
	# Lose a life
	current_lives -= 1
	print("Lives remaining: ", current_lives)
	
	# Check if it's Game Over
	if current_lives <= 0:
		game_over()
		return # <-- MAKE SURE THIS RETURN IS HERE to stop the script instantly!
	
	# Otherwise, reset position back to the origin
	global_position = Vector2(0, 0)
	velocity = Vector2.ZERO


func game_over() -> void:
	# Check if you remembered to assign the Game Over scene file path in the Inspector
	if game_over_scene != "":
		get_tree().change_scene_to_file(game_over_scene)
	else:
		# Safety fallback in case the scene isn't created or assigned yet
		get_tree().reload_current_scene() 
