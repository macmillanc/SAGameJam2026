extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export_file("*.tscn") var map_scene_path: String = "res://scenes/map.tscn"

func _ready() -> void:
	# Connect animation finished signal
	if not animated_sprite_2d.animation_finished.is_connected(_on_animated_sprite_2d_animation_finished):
		animated_sprite_2d.animation_finished.connect(_on_animated_sprite_2d_animation_finished)

	# Fit the animation to the screen size
	fit_to_screen()
	
	# Connect to window resizing so it updates if the user resizes the window
	get_viewport().size_changed.connect(fit_to_screen)

	if Global.highest_level == 0:
		animated_sprite_2d.play("cutscene_one")
	elif Global.highest_level == 1:
		animated_sprite_2d.play("cutscene_two")
	else:
		SceneManager.change_scene(map_scene_path)


func fit_to_screen() -> void:
	# Get the width and height of the current game window viewport
	var viewport_size = get_viewport_rect().size
	
	# Get the width and height of the current cutscene sprite texture frame
	var sprite_texture = animated_sprite_2d.sprite_frames.get_frame_texture(animated_sprite_2d.animation, animated_sprite_2d.frame)
	if sprite_texture == null:
		return
		
	var texture_size = sprite_texture.get_size()
	
	# Position the sprite exactly in the center of the window view
	animated_sprite_2d.global_position = viewport_size / 2.0
	
	# Calculate the correct scale factor to stretch the sprite over the whole screen
	var scale_factor = Vector2(viewport_size.x / texture_size.x, viewport_size.y / texture_size.y)
	animated_sprite_2d.scale = scale_factor


func _on_animated_sprite_2d_animation_finished() -> void:
	SceneManager.change_scene(map_scene_path)
