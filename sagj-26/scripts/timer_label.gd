class_name LevelTimer
extends Label

var elapsed_time: float = 0.0
var timer_active: bool = true

var seasons_used: int = 0
var time_mods_used: int = 0
var current_level_num: int = 1

func _ready() -> void:
	elapsed_time = 0.0
	timer_active = true
	text = "00:00:00"
# Automatically register in the group so the finish line can find it
	if not is_in_group("level_timer"):
		add_to_group("level_timer")

	# Grab current level number from scene path automatically
	var current_scene_path: String = get_tree().current_scene.scene_file_path
	var RegExClass = RegEx.new()
	RegExClass.compile("\\d+")
	var match_result = RegExClass.search(current_scene_path)
	if match_result:
		current_level_num = match_result.get_string().to_int()

	# Styling & top-right anchoring
	anchors_preset = Control.PRESET_TOP_RIGHT
	anchor_left = 1.0
	anchor_right = 1.0
	anchor_top = 0.0
	anchor_bottom = 0.0
	custom_minimum_size = Vector2(240, 40)
	offset_left = -260.0
	offset_right = -20.0
	offset_top = 5.0
	offset_bottom = 45.0
	
	var settings = LabelSettings.new()
	settings.font_size = 32
	settings.font_color = Color.WHITE
	settings.outline_size = 4
	settings.outline_color = Color(0.4, 0.4, 0.4, 1.0)
	settings.shadow_size = 6
	settings.shadow_color = Color(0.0, 0.0, 0.0, 0.6)
	settings.shadow_offset = Vector2(3, 3)
	
	label_settings = settings
	horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func _process(delta: float) -> void:
	if not timer_active:
		return
	elapsed_time += delta
	text = format_time(elapsed_time)

func format_time(time_in_seconds: float) -> String:
	var minutes: int = int(time_in_seconds) / 60
	var seconds: int = int(time_in_seconds) % 60
	var milliseconds: int = int((time_in_seconds - int(time_in_seconds)) * 100)
	return "Time: %02d:%02d:%02d" % [minutes, seconds, milliseconds]

func stop_timer(player_node: Node2D = null) -> void:
	if not timer_active:
		return
	timer_active = false
	
	# Grab stats from player if passed
	if player_node and "level_season_changes_used" in player_node:
		seasons_used = player_node.level_season_changes_used
		time_mods_used = player_node.level_time_mods_used
	
	var final_score = calculate_score()
	
	# 1. POPULATE THE STATS DICTIONARY (This fixes the empty screen!)
	Global.last_run_stats = {
		"level_num": current_level_num,
		"score": final_score,
		"time": elapsed_time,
		"seasons": seasons_used,
		"time_mods": time_mods_used,
		"par_seasons": Global.min_stage.get(current_level_num, 0)
	}
	
	# 2. Save high score
	if not Global.level_scores.has(current_level_num) or final_score > Global.level_scores[current_level_num]:
		Global.level_scores[current_level_num] = final_score

	# 3. Go to the summary scene instead of the map
	SceneManager.change_scene("res://scenes/score_summary.tscn")

func calculate_score() -> int:
	# Total Max = 1000 Points distributed across 3 weights:
	# 1. Season Changes Efficiency (400 points max)
	# 2. Time-Mods (Slows/Speeds) Efficiency (300 points max)
	# 3. Completion Time Speed (300 points max)
	
	# 1. Seasons Score (checks Global.min_stage dictionary)
	var par_stages = Global.min_stage.get(current_level_num, 0)
	var extra_seasons = maxi(0, seasons_used - par_stages)
	var season_score = maxi(0, 400 - (extra_seasons * 100))
	
	# 2. Time-Mod Score (-75 points for each slow/speed used)
	var time_mod_score = maxi(0, 300 - (time_mods_used * 75))
	
	# 3. Time Score (Target par time of 30 seconds; loses ~5 points per second over par)
	var target_par_time: float = 30.0 
	var time_diff = elapsed_time - target_par_time
	var time_score = 300
	if time_diff > 0:
		time_score = maxi(0, 300 - int(time_diff * 5.0))
		
	return season_score + time_mod_score + time_score
