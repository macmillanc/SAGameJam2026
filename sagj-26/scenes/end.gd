extends Area2D

@export var level_index: int = 0 
@export_file("*.tscn") var next_level_scene: String
@export_file("*.tscn") var level_select_scene: String = "res://scenes/level_select.tscn"

var triggered: bool = false

func _on_body_entered(body: Node2D) -> void:
	if triggered:
		return
		
	if body is CharacterBody2D and body.is_in_group("player"):
		triggered = true
		_complete_level.call_deferred(body)

func _complete_level(player: Node2D) -> void:
	print("LEVEL COMPLETE!")

	if level_index + 1 > Global.highest_level:
		Global.highest_level = level_index + 1

	if player.has_method("disable_controls"):
		player.disable_controls()

	if next_level_scene != "":
		get_tree().change_scene_to_file(next_level_scene)
	elif level_select_scene != "":
		get_tree().change_scene_to_file(level_select_scene)
	else:
		push_error("LevelGoal: No valid target scene configured!")
