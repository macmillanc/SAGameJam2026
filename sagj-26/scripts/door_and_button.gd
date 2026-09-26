extends Node2D
var open = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ButtonPlayer.play("ButtonUp")
	$DoorPlayer.play("DoorClosed")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not open:
		$ButtonPlayer.play("ButtonDown")
		$DoorPlayer.play("DoorOpen")
		open = true
