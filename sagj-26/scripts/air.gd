class_name AirState
extends State

func physics_update(delta: float) -> void:
	player.apply_gravity(delta)
	
	var direction := Input.get_axis("left", "right")
	player.apply_horizontal_movement(direction)

	if player.is_on_floor():
		if direction != 0.0:
			state_machine.transition_to("Roll")
		else:
			state_machine.transition_to("Idle")
