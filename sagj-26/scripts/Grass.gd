extends TileMapLayer

func _ready():
	add_to_group("season_objects")
	update_grass()

func update_grass():
	var shader_material: ShaderMaterial = self.material as ShaderMaterial

	if shader_material:
		shader_material.set_shader_parameter("season", Global.season)
