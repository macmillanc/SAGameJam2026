extends AnimatedSprite2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player and "changing_season" in player and player.changing_season:
		speed_scale = 10.0
	else:
		speed_scale = 1.0
