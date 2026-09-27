class_name LevelUI
extends Label

@onready var level_label: LevelUI = $"."

func _ready() -> void:
	setup_level_label()

func setup_level_label() -> void:
	var current_scene_path: String = get_tree().current_scene.scene_file_path
	var file_name: String = current_scene_path.get_file()
	
	var regex = RegEx.new()
	regex.compile("\\d+")
	var match_result = regex.search(file_name)
	
	var level_num: int = match_result.get_string().to_int() if match_result else 1
	var level_name: String = Global.level_names.get(level_num, "Unknown Area") if "level_names" in Global else "Unknown Area"
	
	level_label.text = "Level %d - %s" % [level_num, level_name]
	
	var settings = LabelSettings.new()
	settings.font_size = 32
	settings.font_color = Color.WHITE
	settings.outline_size = 4
	settings.outline_color = Color(0.4, 0.4, 0.4, 1.0)
	settings.shadow_size = 6
	settings.shadow_color = Color(0.0, 0.0, 0.0, 0.6)
	settings.shadow_offset = Vector2(3, 3)
	
	level_label.label_settings = settings
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	level_label.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_interval(1.5)
	tween.tween_property(level_label, "modulate:a", 0.0, 1.0)
	tween.tween_callback(func(): level_label.visible = false)
