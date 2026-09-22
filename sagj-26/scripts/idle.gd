class_name IdleState
extends State

func physics_update(delta: float) -> void:
	# Check air transition first (in case they roll off a ledge)
	if not player.is_on_floor():
		state_machine.transition_to("Air")
		return

	# Check jump transition
	if Input.is_key_pressed(KEY_SPACE):
		player.jump()
		state_machine.transition_to("Air")
		return

	# ONLY transition to manual Roll state if the player inputs a direction
	var direction: float = Input.get_axis("left", "right")
	if direction != 0.0:
		state_machine.transition_to("Roll")
		return

	# --- Slope Rolling Backwards Logic ---
	var floor_normal: Vector2 = player.get_floor_normal()
	
	if abs(floor_normal.x) > 0.05:
		# 1. Steepness factor determines how fast it accelerates
		var steepness: float = abs(floor_normal.x)
		
		# 2. Stage-Based Multiplier
		# Ensures Stage 1 is 1.0x and Stage 5 scales up perfectly to 3.0x
		# Formula: 1.0 + (stage - 1) * 0.5
		# We clamp the stage to a minimum of 1 so Stage 0 doesn't cause a negative multiplier
		var active_stage: float = float(max(1, player.stage))
		var stage_speed_multiplier: float = 1.0 + (active_stage * 8 - 1.0) * 0.5
		
		# Scale up both acceleration and max velocity cap by the stage multiplier
		var scaled_accel: float = player.accel * steepness * stage_speed_multiplier
		var scaled_max_speed: float = player.max_speed * stage_speed_multiplier
		
		# Push the rock downhill automatically
		player.velocity.x += floor_normal.x * scaled_accel * delta
		player.velocity.x = clampf(player.velocity.x, -scaled_max_speed, scaled_max_speed)
	else:
		# On completely flat ground with no player input, decelerate to a stop naturally
		player.apply_horizontal_movement(0.0, delta)
