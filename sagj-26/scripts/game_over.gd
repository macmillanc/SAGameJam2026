extends Control

func _ready() -> void:
	# Connect animation finished signal
	MusicManager.stop_music()
	MusicManager.set_game_speed_pitch(1.0)

func _on_retry_button_pressed() -> void:
	SceneManager.retry_level()

func _on_quit_button_pressed() -> void:
	SceneManager.go_to_map()
