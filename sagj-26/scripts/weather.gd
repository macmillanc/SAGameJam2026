class_name WinterCameraOverlay
extends Sprite2D

@export var winter_season_index: int = 3  # 3 corresponds to Winter

func _ready() -> void:
	# Forces the sprite to ignore the player's movement, rotation, and Y-coordinate changes
	top_level = true 
	
	update_screen_scale()
	get_viewport().size_changed.connect(update_screen_scale)
	
	visible = (Global.season == winter_season_index)

func update_screen_scale() -> void:
	if texture:
		var viewport_size = get_viewport_rect().size
		var tex_size = texture.get_size()
		# Scale the sprite to cover the entire viewport screen
		scale = viewport_size / tex_size

func _process(_delta: float) -> void:
	var is_winter: bool = (Global.season == winter_season_index)
	visible = is_winter
	
	if not is_winter:
		return
		
	# Lock its position directly to the Camera2D so it acts as a screen-space overlay
	var camera = get_viewport().get_camera_2d()
	if camera:
		global_position = camera.get_global_position()
