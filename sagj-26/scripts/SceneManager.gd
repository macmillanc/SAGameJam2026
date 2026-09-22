extends Node

const MAP_SCENE_PATH: String = "res://scenes/map.tscn"

func change_scene(scene_path: String) -> void:
	if scene_path.is_empty():
		push_error("SceneManager: Attempted to load an empty scene path!")
		return
		
	_cleanup_state()
	get_tree().change_scene_to_file(scene_path)

func reload_scene() -> void:
	_cleanup_state()
	get_tree().reload_current_scene()

func retry_level() -> void:
	if Global.last_played_level != "":
		change_scene(Global.last_played_level)
	else:
		push_error("SceneManager: No last played level found!")

func go_to_map() -> void:
	change_scene(MAP_SCENE_PATH)

func game_over(game_over_scene: String = "") -> void:
	Global.season = 0
	if game_over_scene != "":
		change_scene(game_over_scene)
	else:
		reload_scene()

#resets engine time and stops dialog
func _cleanup_state() -> void:
	Engine.time_scale = 1.0
	
	if DialogManager.has_method("stop_dialog"):
		DialogManager.stop_dialog()
