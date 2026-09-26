extends Node2D

@export var line_drawer: Node2D
@export var levels_container: Node2D
@export var camera: Camera2D

@export_group("Camera Settings")
@export var camera_speed: float = 400.0
@export var level_music: AudioStream

func _ready() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	refresh_map()
	MusicManager.stop_music()
	if level_music:
		MusicManager.play_music(level_music)

func _process(delta: float) -> void:
	_handle_camera_movement(delta)

func _input(event: InputEvent) -> void:
	# Dev Command: Spacebar unlocks next stage
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE:
			_dev_unlock_next_level()

func _dev_unlock_next_level() -> void:
	var total_levels: int = levels_container.get_child_count() if levels_container else 5
	
	# Fix: Stop at total_levels - 1 (index 4 for 5 levels)
	if Global.highest_level < total_levels - 1:
		Global.highest_level += 1
		print("DEV: Unlocked up to Level Index ", Global.highest_level)
		refresh_map()
	else:
		print("DEV: All levels already unlocked!")

func _handle_camera_movement(delta: float) -> void:
	if not camera:
		return
		
	var input_dir := Vector2.ZERO
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input_dir.x += 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		input_dir.x -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input_dir.y += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		input_dir.y -= 1.0

	if input_dir != Vector2.ZERO:
		camera.global_position += input_dir.normalized() * camera_speed * delta

func refresh_map() -> void:
	if not levels_container:
		return
		
	for child in levels_container.get_children():
		if child.has_method("update_level_state"):
			child.update_level_state()
			
	if line_drawer and line_drawer.has_method("redraw_connections"):
		line_drawer.redraw_connections()
