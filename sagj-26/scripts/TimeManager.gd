extends Node

signal time_scale_changed(is_slowed: bool)

var is_slowed: bool = false

func scale_time(duration: float, percentage: float, canvas_modulate: CanvasModulate = null) -> void:
	if is_slowed:
		return
	is_slowed = true
	Engine.time_scale = percentage
	
	if canvas_modulate:
		var target_color = Color(0.6, 0.8, 1.0, 1.0) if percentage < 1.0 else Color(1.0, 0.7, 0.6, 1.0)
		create_tween().set_ignore_time_scale(true).tween_property(canvas_modulate, "color", target_color, 0.25)
	
	await get_tree().create_timer(duration, true, false, true).timeout
	
	Engine.time_scale = 1.0
	is_slowed = false
	
	if canvas_modulate:
		create_tween().set_ignore_time_scale(true).tween_property(canvas_modulate, "color", Color.WHITE, 0.25)
