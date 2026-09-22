extends Parallax2D

@export var base_cloud_speed: float = 15.0
@export var season_boost_speed: float = 1200.0 # Extremely fast cloud movement during season shift
@export var fast_forward_multiplier: float = 3.0

func _process(delta: float) -> void:
	var current_speed: float = base_cloud_speed

	var player = get_tree().get_first_node_in_group("player")
	if player and "changing_season" in player and player.changing_season:
		# Immediately switch to ultra-fast speed while season is transitioning
		current_speed = season_boost_speed
	elif Engine.time_scale > 1.0:
		current_speed *= fast_forward_multiplier

	scroll_offset.x += current_speed * delta
