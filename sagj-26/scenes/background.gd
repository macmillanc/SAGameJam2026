extends Node2D

# Assign all 7 layers in chronological order in the Inspector
@export var sky_sprites: Array[Sprite2D] = []
@export var parallax_cloud_sprites: Array[Sprite2D] = []
@export var large_cloud_sprites: Array[Sprite2D] = []

# Length of a full day cycle in seconds
@export var day_length_seconds: float = 120.0 
@export var fast_forward_boost: float = 100.0

var time_of_day: float = 0.0 # Ranges from 0.0 to 1.0
var direction: float = 1.0

func _process(delta: float) -> void:
	# Advance time and ping-pong back/forth
	var speed_multiplier: float = 1.0
	if Engine.time_scale > 1.0:
		speed_multiplier = fast_forward_boost
		
	time_of_day += direction * (delta * speed_multiplier) / day_length_seconds
	if time_of_day >= 1.0 or time_of_day <= 0.0:
		direction *= -1
		time_of_day = clamp(time_of_day, 0.0, 1.0)
		
	update_atmosphere_alpha(time_of_day)

func update_atmosphere_alpha(t: float) -> void:
	var total_stages := sky_sprites.size()
	if total_stages == 0:
		return

	# Calculate transition segments across all array stages
	var num_segments := total_stages - 1
	var raw_index := t * num_segments
	
	var current_index := int(floor(raw_index))
	current_index = clamp(current_index, 0, num_segments - 1)
	var next_index := current_index + 1

	# Blend factor between the current active stage and the next (0.0 to 1.0)
	var blend_factor := raw_index - float(current_index)

	# Update alpha values for skies and clouds simultaneously
	for i in range(total_stages):
		var target_alpha := 0.0

		if i == current_index:
			target_alpha = 1.0 - blend_factor # Fading out
		elif i == next_index:
			target_alpha = blend_factor      # Fading in

		# Apply calculated alpha to all three layer groups
		_set_sprite_alpha(sky_sprites, i, target_alpha)
		_set_sprite_alpha(parallax_cloud_sprites, i, target_alpha)
		_set_sprite_alpha(large_cloud_sprites, i, target_alpha)

# Helper function to prevent null pointer crashes if an array slot is empty
func _set_sprite_alpha(sprite_array: Array[Sprite2D], index: int, alpha: float) -> void:
	if index < sprite_array.size() and sprite_array[index] != null:
		sprite_array[index].self_modulate.a = alpha
