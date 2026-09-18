extends Control

func _on_retry_button_pressed() -> void:
	# Check if a level path was successfully saved before loading it
	if Global.last_played_level != "":
		get_tree().change_scene_to_file(Global.last_played_level)
	else:
		print("Error: No level path was recorded in Global!")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
