extends Node2D

var open = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ButtonPlayer.play("ButtonUp")
	$DoorPlayer.play("DoorClosed")


func _on_area_2d_body_entered(body: Node2D) -> void:
	# Check if the body itself OR its parent wrapper belongs to the "object" group
	if (body.is_in_group("object") or body.get_parent().is_in_group("object")) and not open:
		$ButtonPlayer.play("ButtonDown")
		$DoorPlayer.play("DoorOpen")
		open = true
