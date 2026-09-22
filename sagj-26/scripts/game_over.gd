extends Control

func _on_retry_button_pressed() -> void:
	SceneManager.retry_level()

func _on_quit_button_pressed() -> void:
	SceneManager.go_to_map()
