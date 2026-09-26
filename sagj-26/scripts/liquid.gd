extends TileMapLayer

@export var water_rise_duration: float = 1.5

var starting_water_y: float
var water_rise_steps: int = 0
const WATER_BLOCK_HEIGHT: float = 32.0


func _ready() -> void:
	add_to_group("season_objects")
	add_to_group("liquid_layer")

	# Remember where the water originally was in the editor.
	starting_water_y = position.y

	# RESET: Start completely fresh at the base level position
	water_rise_steps = 0
	position.y = starting_water_y

	apply_season_intensity()


# Called by Player when the season changes.
func update_waves() -> void:
	apply_season_intensity()
	update_water_level()


# --------------------------------------------------
# WATER LEVEL
# --------------------------------------------------

func update_water_level() -> void:
	# Increment the rise counter by 1 every time the season changes
	water_rise_steps += 1
	
	var new_y: float = starting_water_y - (water_rise_steps * WATER_BLOCK_HEIGHT)

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		self,
		"position:y",
		new_y,
		water_rise_duration
	)


# --------------------------------------------------
# WAVE SHADER
# --------------------------------------------------

func apply_season_intensity() -> void:
	var base_mat: ShaderMaterial = null
	var using_canvas_slot: bool = true

	if material is ShaderMaterial:
		base_mat = material as ShaderMaterial
		using_canvas_slot = true

	elif tile_set and tile_set.get("rendering/material") is ShaderMaterial:
		base_mat = tile_set.get("rendering/material") as ShaderMaterial
		using_canvas_slot = false

	if not base_mat:
		push_error(
			"LIQUID ENGINE ERROR: ShaderMaterial missing from node properties!"
		)
		return

	# Make this material unique so changing the waves does not
	# modify every other water surface using the same material.
	var unique_mat: ShaderMaterial = base_mat.duplicate()

	# Force neon green color

	var config: Dictionary = Global.get_current_wave_settings()

	unique_mat.set_shader_parameter(
		"wave_height",
		config["height"]
	)

	unique_mat.set_shader_parameter(
		"wave_frequency",
		config["freq"]
	)

	unique_mat.set_shader_parameter(
		"wave_speed",
		config["speed"]
	)

	unique_mat.set_shader_parameter(
		"flow_speed",
		config["flow"]
	)

	if using_canvas_slot:
		material = unique_mat
	else:
		tile_set.set("rendering/material", unique_mat)
