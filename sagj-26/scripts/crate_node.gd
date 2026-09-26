extends Node2D

# Expose current_stage to the top-level Inspector
@export_enum("Very Damaged:1", "Slightly Damaged:2", "Undamaged:3", "Rotten Very Damaged:4", "Rotten Slightly Damaged:5") var current_stage: int = 3

@onready var crate_body: Crate = $Crate # Change $Crate to your actual child node name

func _ready() -> void:
	# AUTOMATIC FIX: Adds the root node to the "object" group so the spring detects it
	add_to_group("object")
	
	if crate_body:
		crate_body.current_stage = current_stage
		crate_body.update_texture()

# --- Physics Spring Function ---
func spring(springJump: float) -> void:
	if crate_body:
		# 1. Reset its current falling momentum so it doesn't fight the launch
		crate_body.linear_velocity.y = 0
		
		# 2. Apply a central impulse upwards (RigidBody2D handles gravity naturally)
		crate_body.apply_central_impulse(Vector2(0, -springJump / 10))
