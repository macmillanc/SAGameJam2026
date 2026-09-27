extends Area2D

@export var level_index: int = 0 
@export_file("*.tscn") var level_select_scene: String = "res://scenes/score_screen.tscn"

var triggered: bool = false

func _on_body_entered(body: Node2D) -> void:
	if triggered:
		return
		
	if body is CharacterBody2D and body.is_in_group("player"):
		triggered = true
		_complete_level.call_deferred(body)

func _complete_level(player: Node2D) -> void:
	# 1. Find the timer in the scene to grab elapsed time safely
	var timer_node = get_tree().get_first_node_in_group("level_timer")
	var elapsed_time: float = 0.0
	if timer_node and "elapsed_time" in timer_node:
		elapsed_time = float(timer_node.elapsed_time)
		if timer_node.has_method("stop_timer"):
			timer_node.stop_timer()

	# 2. Grab player stats safely using the 'in' keyword
	var seasons_used: int = 0
	if player and "level_season_changes_used" in player:
		seasons_used = int(player.level_season_changes_used)
		
	var time_mods_used: int = 0
	if player and "level_time_mods_used" in player:
		time_mods_used = int(player.level_time_mods_used)

	var deaths_used: int = 0
	if player and "level_deaths" in player:
		deaths_used = int(player.level_deaths)
	
	# 3. Calculate score with new penalties (Starts at 1000 max)
	var par_stages: int = int(Global.min_stage.get(level_index, 0))
	var extra_seasons: int = maxi(0, seasons_used - par_stages)
	
	var death_penalty = deaths_used * 20
	var season_penalty = extra_seasons * 50
	var time_mod_penalty = time_mods_used * 10
	
	var target_par_time: float = 30.0 
	var time_diff: float = elapsed_time - target_par_time
	var time_penalty: int = int(maxf(0.0, time_diff) * 5.0)
	
	var final_score: int = maxi(0, 1000 - death_penalty - season_penalty - time_mod_penalty - time_penalty)

	# 4. Populate Global stats for the summary screen
	Global.last_run_stats = {
		"level_num": level_index,
		"score": final_score,
		"time": elapsed_time,
		"seasons": seasons_used,
		"time_mods": time_mods_used,
		"deaths": deaths_used,
		"par_seasons": par_stages
	}

	# 5. Save high score
	if not Global.level_scores.has(level_index) or final_score > Global.level_scores[level_index]:
		Global.level_scores[level_index] = final_score

	# 6. Progression logic
	Global.season = 0
	Global.highest_level = level_index + 1
	Global.season_transitions = 0
	SceneManager.change_scene("res://cutscene_2.tscn")
	return

	if level_index + 1 > Global.highest_level:
		Global.highest_level = level_index + 1

	if player.has_method("disable_controls"):
		player.call("disable_controls")

	# RESET SEASONS WHEN LEAVING THE LEVEL
	Global.season = 0
	Global.season_transitions = 0

	# Go to the score screen scene
	SceneManager.change_scene(level_select_scene)
