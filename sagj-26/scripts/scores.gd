extends Control
@export var score_list_container: VBoxContainer

func _ready() -> void:
	display_high_scores()

func display_high_scores() -> void:
	if not score_list_container:
		push_error("HighScoreContainer node could not be found!")
		return

	# Clear any existing placeholder labels
	for child in score_list_container.get_children():
		child.queue_free()

	# Get level numbers and sort them numerically (1, 2, 3, 4, 5)
	var level_keys = Global.level_names.keys()
	level_keys.sort()

	for lvl_num in level_keys:
		var level_name = Global.level_names[lvl_num]
		
		# Directly fetch the score using the exact level number key (e.g., 1, 2, 3...)
		var score = Global.level_scores.get(lvl_num, 0)
		print (score)
		print (lvl_num)
		
		var score_label = Label.new()
		score_label.text = "Level %d (%s): %d / 1000" % [lvl_num, level_name, score]
		score_label.add_theme_font_size_override("font_size", 16)
		
		score_list_container.add_child(score_label)
