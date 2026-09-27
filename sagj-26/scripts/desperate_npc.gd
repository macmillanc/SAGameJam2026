extends CharacterBody2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

# 1. Define sets of lines for different levels


const LEVEL_5_LINES: Array[String] = [
	"Alright I understand that they did just kinda leave us to die",
	"But don't you want to see what's on the mountain",
	"I mean being completely honest if you've ran this far away",
	"I can't stop you . . .",
	"Barnacles"
]

const DEFAULT_LINES: Array[String] = [
	"Barnacles"
]

func _ready():
	interaction_area.interact = Callable(self, "_on_interact")
	
func _on_interact():
	
	audio_stream_player_2d.play()
	# 2. Figure out which level we are currently on
	var level_num: int = _get_current_level_number()
	
	# 3. Choose the correct lines based on the level
	var active_lines: Array[String] = DEFAULT_LINES
	match level_num:
		5:
			active_lines = LEVEL_5_LINES
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
