extends Node2D

# Expose current_stage to the top-level Inspector
@export_enum("Very Damaged:1", "Slightly Damaged:2", "Undamaged:3") var current_stage: int = 3

@onready var crate_body: Crate = $Crate # Change $Crate to your actual child node name

func _ready() -> void:
	if crate_body:
		crate_body.current_stage = current_stage
		crate_body.update_texture()
