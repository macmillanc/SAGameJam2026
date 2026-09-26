extends TileMapLayer

@export var water_rise_duration: float = 1.5

var starting_water_y: float
var water_rise_steps: int = 0
const WATER_BLOCK_HEIGHT: float = 50.0


func _ready() -> void:
	add_to_group("season_objects")
	add_to_group("liquid_layer")

	# Remember where the water originally was in the editor.
	starting_water_y = position.y

	# RESET: Start completely fresh at the base level position
	water_rise_steps = 0
	position.y = starting_water_y

	# HIJACK THE SHADER TEXT CODE DIRECTLY AND FORCE IT GREEN
	inject_green_into_shader()
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
# SHADER INJECTION
# --------------------------------------------------

func inject_green_into_shader() -> void:
	var target_mat: ShaderMaterial = null
	
	if material is ShaderMaterial:
		target_mat = material as ShaderMaterial
	elif tile_set and tile_set.get("rendering/material") is ShaderMaterial:
		target_mat = tile_set.get("rendering/material") as ShaderMaterial

	if target_mat and target_mat.shader:
		var original_code: String = target_mat.shader.code
		
		# If we haven't modified this shader string yet
		if not original_code.contains("acid_override"):
			# Find the very last closing bracket of the fragment function
			var last_bracket: int = original_code.rfind("}")
			if last_bracket != -1:
				# Inject code right before the fragment function finishes.
				# This overrides any blue values assigned earlier in the shader 
				# and forces the blue/red channels to 0 while keeping alpha and wave movement!
				var injection: String = "\n\t// acid_override\n\tCOLOR.g = (COLOR.r + COLOR.g + COLOR.b) * 1.5;\n\tCOLOR.r = 0.0;\n\tCOLOR.b = 0.0;\n"
				var modified_code: String = original_code.insert(last_bracket, injection)
				
				# Build and swap the modified shader 
				var new_shader = Shader.new()
				new_shader.code = modified_code
				target_mat.shader = new_shader


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
		return

	var unique_mat: ShaderMaterial = base_mat.duplicate()
	var config: Dictionary = Global.get_current_wave_settings()

	unique_mat.set_shader_parameter("wave_height", config["height"])
	unique_mat.set_shader_parameter("wave_frequency", config["freq"])
	unique_mat.set_shader_parameter("wave_speed", config["speed"])
	unique_mat.set_shader_parameter("flow_speed", config["flow"])

	if using_canvas_slot:
		material = unique_mat
	else:
		tile_set.set("rendering/material", unique_mat)
