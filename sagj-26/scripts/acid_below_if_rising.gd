extends TileMapLayer


func _ready() -> void:
	add_to_group("season_objects")
	add_to_group("liquid_layer")

	# HIJACK THE SHADER TEXT CODE DIRECTLY AND FORCE IT GREEN
	inject_green_into_shader()


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
