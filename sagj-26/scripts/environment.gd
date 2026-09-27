class_name EnvironmentUtils

static func get_water_multiplier(tree: SceneTree, global_pos: Vector2) -> float:
	var water_layers = tree.get_nodes_in_group("liquid_layer")
	if water_layers.is_empty():
		return 1.0
		
	var water_layer = water_layers[0] as TileMapLayer
	if water_layer:
		var tile_pos = water_layer.local_to_map(water_layer.to_local(global_pos))
		var tile_data = water_layer.get_cell_tile_data(tile_pos)
		if tile_data and tile_data.get_custom_data("is_water"):
			return 0.5
	return 1.0

static func is_in_deadly_hazard(tree: SceneTree, global_pos: Vector2) -> bool:
	var water_layers = tree.get_nodes_in_group("liquid_layer")
	for layer in water_layers:
		if layer is TileMapLayer:
			var tile_pos = layer.local_to_map(layer.to_local(global_pos))
			var tile_data = layer.get_cell_tile_data(tile_pos)
			if tile_data and tile_data.get_custom_data("is_deadly"):
				return true
	return false
