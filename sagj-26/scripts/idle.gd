class_name IdleState
extends State

func physics_update(_delta: float) -> void:
	player.apply_horizontal_movement(0.0)

	if not player.is_on_floor():
		state_machine.transition_to("Air")
		return

	if Input.is_key_pressed(KEY_SPACE):
		player.jump()
		state_machine.transition_to("Air")
		return

	var direction := Input.get_axis("left", "right")
	if direction != 0.0:
		state_machine.transition_to("Roll")
