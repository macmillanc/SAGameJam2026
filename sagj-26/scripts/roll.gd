class_name MoveState
extends State

func physics_update(_delta: float) -> void:
	var direction := Input.get_axis("left", "right")
	player.apply_horizontal_movement(direction)

	if not player.is_on_floor():
		state_machine.transition_to("Air")
		return

	if Input.is_action_just_pressed("jump"):
		player.jump()
		state_machine.transition_to("Air")
		return

	if direction == 0.0 and abs(player.velocity.x) < 5.0:
		state_machine.transition_to("Idle")
