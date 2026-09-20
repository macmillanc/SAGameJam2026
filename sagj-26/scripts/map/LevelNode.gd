extends TextureButton

# Set in Inspector: Level0 = 0, Level1 = 1, Level2 = 2, Level3 = 3, Level4 = 4
@export var level_num: int = 0
@export var spritesheet: Texture2D

const FRAME_SIZE: Vector2 = Vector2(64, 64)

func _ready() -> void:
	# Prevent UI focus from stealing Spacebar input
	focus_mode = FOCUS_NONE
	
	# Set up 4x scaling (256x256) bounds
	custom_minimum_size = Vector2(256, 256)
	size = Vector2(256, 256)
	pivot_offset = Vector2(128, 128)
	mouse_filter = MOUSE_FILTER_STOP
	
	ignore_texture_size = true
	stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)
		
	update_level_state()

func update_level_state() -> void:
	var is_unlocked: bool = level_num <= Global.highest_level
	
	visible = is_unlocked
	disabled = not is_unlocked
	
	if is_unlocked:
		if spritesheet:
			_apply_atlas_frame()
		queue_redraw()

func _apply_atlas_frame() -> void:
	var atlas = AtlasTexture.new()
	atlas.atlas = spritesheet
	
	# Slices 5x1 spritesheet: Level 0 -> 0px, Level 1 -> 64px, etc.
	var frame_idx: int = clamp(level_num, 0, 4)
	atlas.region = Rect2(frame_idx * FRAME_SIZE.x, 0, FRAME_SIZE.x, FRAME_SIZE.y)
	texture_normal = atlas

func _on_pressed() -> void:
	# Maps Level 0 -> res://scenes/level_1.tscn, Level 1 -> res://scenes/level_2.tscn, etc.
	var scene_file_number: int = level_num + 1
	var scene_path: String = "res://scenes/level%d.tscn" % scene_file_number

	if ResourceLoader.exists(scene_path):
		get_tree().change_scene_to_file(scene_path)
	else:
		push_error("Could not find level scene at path: %s" % scene_path)
