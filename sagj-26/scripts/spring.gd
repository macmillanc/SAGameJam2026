extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

# NOTE: For RigidBody2D, a lower number like 400 or 600 works well. 
# If 5000 launches it out of the map, turn this down!
@export var jump := 5000 

func _on_body_entered(body: Node2D) -> void:
	# Check if the body itself OR its parent wrapper is part of the "object" group
	if body.is_in_group("object") or body.get_parent().is_in_group("object"):
		
		# Call the spring function on whichever node holds it
		if body.has_method("spring"):
			body.spring(jump)
		elif body.get_parent().has_method("spring"):
			body.get_parent().spring(jump)
			
		animated_sprite_2d.play("bounce")
		audio_stream_player_2d.play()

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "bounce":
		animated_sprite_2d.play("idle")
