class_name GameCamera
extends Camera2D

func apply_shake(impact_force: float) -> void:
	var intensity: float = clampf(impact_force / 50.0, 2.0, 12.0)
	var tween = create_tween()

	for i in range(4):
		var offset_pos = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		tween.tween_property(self, "offset", offset_pos, 0.03)

	tween.tween_property(self, "offset", Vector2.ZERO, 0.05)
