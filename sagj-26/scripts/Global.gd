extends Node

# This variable will save the file path of whatever level the player is currently in
var last_played_level: String = ""
var season = 0
var highest_level = 0
 # Map level numbers to their display names
var level_names: Dictionary = {
	1: "Cloud 9",
	2: "Deep Water",
	3: "Pollution inc",
	4: "Deserted",
	5: "Mt Doom"
}

var min_stage: Dictionary = {
	1: 1,
	2: 0,
	3: 0,
	4: 0,
	5: 0
}
