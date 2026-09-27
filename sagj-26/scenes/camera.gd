class_name SmoothCamera
extends Camera2D

@export_group("Targeting")
@export var target_node: Node2D

@export_group("Off-Center Settings")
@export var screen_offset: Vector2 = Vector2(0, -60)
@export var look_ahead_distance: Vector2 = Vector2(180.0, 80.0)
@export var look_ahead_speed: float = 3.5

@export_group("Follow Dynamics")
@export var follow_smoothness: float = 6.0


var _current_look_ahead: Vector2 = Vector2.ZERO


func _ready() -> void:
	top_level = true
	
	if not target_node:
		target_node = get_tree().get_first_node_in_group("player") as Node2D


func _process(delta: float) -> void:
	if not is_instance_valid(target_node):
		target_node = get_tree().get_first_node_in_group("player") as Node2D
		if not target_node:
			return
	var player_velocity := Vector2.ZERO
	if target_node is CharacterBody2D:
		player_velocity = target_node.velocity
		
	var target_look_ahead := Vector2.ZERO
	if player_velocity.length_squared() > 100.0:
		target_look_ahead = player_velocity.normalized() * look_ahead_distance
	_current_look_ahead = _current_look_ahead.lerp(target_look_ahead, look_ahead_speed * delta)

	var desired_position: Vector2 = target_node.global_position + screen_offset + _current_look_ahead
	global_position = global_position.lerp(desired_position, follow_smoothness * delta)
