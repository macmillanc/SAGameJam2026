extends Parallax2D

@export var base_cloud_speed: float = 10.0
@export var fast_forward_boost: float = 50.0 # Extra multiplier during fast forward

func _process(delta: float) -> void:
	var current_boost := 1.0
	
	# If time scale is boosted, give clouds an extra push to match player feel
	if Engine.time_scale > 1.0:
		current_boost = fast_forward_boost

	# Scroll clouds
	scroll_offset.x += base_cloud_speed * current_boost * delta
