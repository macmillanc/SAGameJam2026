extends Area2D

@export var level_index: int = 0 
@export_file("*.tscn") var level_select_scene: String = "res://scenes/map.tscn"

var triggered: bool = false

func _on_body_entered(body: Node2D) -> void:
	if triggered:
		return
		
	if body is CharacterBody2D and body.is_in_group("player"):
		triggered = true
		_complete_level.call_deferred(body)

func _complete_level(player: Node2D) -> void:
	print(Global.highest_level)
	if Global.highest_level == 0:
		Global.season = 0
		Global.highest_level = level_index + 1
		Global.season_transitions = 0
		SceneManager.change_scene("res://cutscene.tscn")
		return
	if level_index + 1 > Global.highest_level:
		Global.highest_level = level_index + 1

	if player.has_method("disable_controls"):
		player.call("disable_controls")

	# RESET SEASONS WHEN LEAVING THE LEVEL
	Global.season = 0
	Global.season_transitions = 0

	SceneManager.change_scene(level_select_scene)
