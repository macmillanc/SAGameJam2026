extends Node

var last_played_level: String = ""
var season: int = 0
var highest_level: int = 0

# Total number of season changes that have happened.
# This NEVER goes backwards when the season loops back to Spring.
var season_transitions: int = 0


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


# --------------------------------------------------
# WATER
# --------------------------------------------------

# Water rises by one 32x32 block every 2 transitions.
const WATER_RISE_TRANSITIONS: int = 1
const WATER_BLOCK_HEIGHT: float = 32.0


func get_water_rise() -> float:
	return floori(float(season_transitions) / WATER_RISE_TRANSITIONS) * WATER_BLOCK_HEIGHT


# --------------------------------------------------
# WAVES
# --------------------------------------------------

const SEASON_WAVE_SETTINGS = {
	# Spring
	0: {
		"height": 3.0,
		"freq": 0.06,
		"speed": 1.5,
		"flow": 0.3
	},

	# Summer
	1: {
		"height": 4.5,
		"freq": 0.045,
		"speed": 2.2,
		"flow": 0.55
	},

	# Autumn
	2: {
		"height": 5.5,
		"freq": 0.035,
		"speed": 5.5,
		"flow": 0.9
	},

	# Winter
	3: {
		"height": 4.5,
		"freq": 0.045,
		"speed": 2.2,
		"flow": 0.55
	},
}


func get_current_wave_settings() -> Dictionary:
	var season_index: int = 0
	
	# Set this to the total number of transitions where your final season occurs 
	# (e.g., if your game ends after 4 full cycles / 16 total transitions)
	const FINAL_SEASON_TRANSITION_COUNT: int = 16 

	if season_transitions >= FINAL_SEASON_TRANSITION_COUNT:
		season_index = 4
	else:
		season_index = clampi(season, 0, 3)

	# Every complete 4-season cycle permanently increases intensity.
	var intensity_cycle: int = season_transitions / 4

	var target_settings = SEASON_WAVE_SETTINGS[season_index] if SEASON_WAVE_SETTINGS.has(season_index) else SEASON_WAVE_SETTINGS[3]
	var settings: Dictionary = target_settings.duplicate()

	# Permanent increase in wave aggression.
	settings["height"] += intensity_cycle * 2.0
	settings["speed"] += intensity_cycle * 0.5
	settings["flow"] += intensity_cycle * 0.15

	# Lower frequency = longer/wider waves.
	settings["freq"] = maxf(
		settings["freq"] - intensity_cycle * 0.003,
		0.015
	)

	return settings
