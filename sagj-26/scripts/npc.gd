extends CharacterBody2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite_2d: Sprite2D = $Sprite2D

const lines: Array[String] = [
	"Hey :)",
	"So..Press [I] to change seasons",
	"Press [O] to slow down time",
	"Finally, press [P] to speed up time!"
]

func _ready():
	interaction_area.interact = Callable(self, "_on_interact")
	
func _on_interact():
	DialogManager.start_dialog(global_position, lines)
	await DialogManager.dialog_finished
