extends CharacterBody2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite_2d: Sprite2D = $Sprite2D

const lines: Array[String] = [
	"Hey, you're about to miss the show :O [Press E to Continue]",
	"Press [I] to change seasons [Press E to Continue]",
	"Press [O] to slow down time [Press E to Continue]",
	"Finally, press [P] to speed up so you're not more late XD!"
]

func _ready():
	interaction_area.interact = Callable(self, "_on_interact")
	
func _on_interact():
	DialogManager.start_dialog(global_position, lines)
	await DialogManager.dialog_finished
