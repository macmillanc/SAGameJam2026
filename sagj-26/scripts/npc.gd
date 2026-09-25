extends CharacterBody2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite_2d: Sprite2D = $Sprite2D

# 1. Define sets of lines for different levels
const LEVEL_1_LINES: Array[String] = [
	"Hey, you're about to miss the show :O Press [Enter] to Continue",
	"Press [I] to change seasons",
	"Press [O] to slow down time",
	"And, press [P] to speed up so you're not more late XD!"
]

const LEVEL_2_LINES: Array[String] = [
	"Well I guess we've both fallen down here huh",
	"Hopefully the other rocks are still around here somewhere . . .",
	"Anyway that river to the right looks very dangerous but it seems to be the only way forward",
	"You might need to slow down things when trying to cross it",
	"Also remember two things",
	"If you're slower you can jump higher",
	"And don't drown XD"
]

const LEVEL_3_LINES: Array[String] = [
	"Well this seems to be where the crates are from",
	"And it seems to be a bit unsafe",
	"With all the acid and all . . ."
	
]

const DEFAULT_LINES: Array[String] = [
	"Keep pushing forward! [Press E to Continue]"
]

func _ready():
	interaction_area.interact = Callable(self, "_on_interact")
	
func _on_interact():
	# 2. Figure out which level we are currently on
	var level_num: int = _get_current_level_number()
	
	# 3. Choose the correct lines based on the level
	var active_lines: Array[String] = DEFAULT_LINES
	match level_num:
		1:
			active_lines = LEVEL_1_LINES
		2:
			active_lines = LEVEL_2_LINES
		3:
			active_lines = LEVEL_3_LINES
		# Add more levels here as you build them (e.g., 3: LEVEL_3_LINES)

	# 4. Start the dialog with the selected lines
	DialogManager.start_dialog(global_position, active_lines)
	await DialogManager.dialog_finished


# Helper function to parse the level number from the scene file path
func _get_current_level_number() -> int:
	var current_scene_path: String = get_tree().current_scene.scene_file_path
	var file_name: String = current_scene_path.get_file()
	
	var RegExClass = RegEx.new()
	RegExClass.compile("\\d+")
	var match_result = RegExClass.search(file_name)
	
	if match_result:
		return match_result.get_string().to_int()
	return 1
