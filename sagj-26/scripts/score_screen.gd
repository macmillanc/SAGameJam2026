class_name ScoreSummaryScreen
extends Control

@onready var title_label: Label = $ColorRect/CenterContainer/PanelContainer/VBoxContainer/Label
@onready var time_label: Label = $ColorRect/CenterContainer/PanelContainer/VBoxContainer/VBoxContainer/time_label
@onready var season_label: Label = $ColorRect/CenterContainer/PanelContainer/VBoxContainer/VBoxContainer/season_label
@onready var time_mod_label: Label = $ColorRect/CenterContainer/PanelContainer/VBoxContainer/VBoxContainer/time_manipulation_label
@onready var death_label: Label = $ColorRect/CenterContainer/PanelContainer/VBoxContainer/VBoxContainer/death_label
@onready var score_label: Label = $ColorRect/CenterContainer/PanelContainer/VBoxContainer/score_label
@onready var retry_button: Button = $ColorRect/CenterContainer/PanelContainer/VBoxContainer/HBoxContainer/retry
@onready var map_button: Button = $ColorRect/CenterContainer/PanelContainer/VBoxContainer/HBoxContainer/quit


func _ready() -> void:
	if retry_button:
		retry_button.pressed.connect(_on_retry_button_pressed)
	if map_button:
		map_button.pressed.connect(_on_quit_button_pressed)
	
	if Global.last_run_stats.is_empty():
		return
		
	var lvl_num = Global.last_run_stats.get("level_num", 1)
	var score = Global.last_run_stats.get("score", 0)
	var time_sec = Global.last_run_stats.get("time", 0.0)
	var seasons = Global.last_run_stats.get("seasons", 0)
	var par_seasons = Global.last_run_stats.get("par_seasons", 0)
	var time_mods = Global.last_run_stats.get("time_mods", 0)
	var deaths = Global.last_run_stats.get("deaths", 0)
	
	title_label.text = "Level %d Complete!" % lvl_num
	
	var minutes = int(time_sec) / 60
	var seconds = int(time_sec) % 60
	var ms = int((time_sec - int(time_sec)) * 100)
	time_label.text = "Time Taken: %02d:%02d:%02d" % [minutes, seconds, ms]
	
	if death_label:
		death_label.text = "💀 Deaths: %d" % deaths
		
	season_label.text = "Seasons Used: %d" % [seasons]
	time_mod_label.text = "Time-Mods Used: %d" % [time_mods]
	
	score_label.text = "Score: %d / 1000" % score


func _on_retry_button_pressed() -> void:
	SceneManager.retry_level()


func _on_quit_button_pressed() -> void:
	SceneManager.go_to_map()
