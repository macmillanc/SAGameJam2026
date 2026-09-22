extends TileMapLayer

# Caches the baseline layout data of your level upon initial load
var _original_grass_rows: Dictionary = {}

func _ready() -> void:
	add_to_group("season_objects")
	
	# Map out existing grass tiles to protect their height limits from overflowing
	for cell in get_used_cells():
		var atlas_coords: Vector2i = get_cell_atlas_coords(cell)
		_original_grass_rows[cell] = atlas_coords.y
		
	update_grass()


func update_grass() -> void:
	# 1. Update seasonal shader parameters
	var shader_material: ShaderMaterial = self.material as ShaderMaterial
	if shader_material:
		shader_material.set_shader_parameter("season", Global.season)

	# To prevent updating a tile and immediately checking it as a neighbor for the next cell,
	# we calculate all changes first and apply them after the loop.
	var pending_changes: Dictionary = {}

	# 2. Evaluate growth conditions for each active cell
	for cell in get_used_cells():
		var atlas_coords: Vector2i = get_cell_atlas_coords(cell)
		
		# Define coordinates for left and right neighbors
		var left_cell: Vector2i = cell + Vector2i(-1, 0)
		var right_cell: Vector2i = cell + Vector2i(1, 0)
		
		var has_left_neighbor: bool = get_cell_source_id(left_cell) != -1
		var has_right_neighbor: bool = get_cell_source_id(right_cell) != -1
		
		var can_grow: bool = true
		
		# Neighbor Constraint Checklist:
		# If a neighbor exists, it must be at least at our current Y coordinate (same or longer stage)
		if has_left_neighbor:
			var left_atlas: Vector2i = get_cell_atlas_coords(left_cell)
			if left_atlas.y < atlas_coords.y:
				can_grow = false
				
		if has_right_neighbor:
			var right_atlas: Vector2i = get_cell_atlas_coords(right_cell)
			if right_atlas.y < atlas_coords.y:
				can_grow = false

		# If neighbors are blocking it, skip this tile entirely
		if not can_grow:
			continue

		# 3. Roll our standard 50% probability check if conditions pass
		if randf() < 0.5:
			var source_id: int = get_cell_source_id(cell)
			var alternative_tile: int = get_cell_alternative_tile(cell)
			
			# Retrieve baseline row boundaries to protect against empty tile atlas slots
			var base_y: int = _original_grass_rows.get(cell, atlas_coords.y)
			var max_y: int = base_y + 2
			
			var new_atlas_y: int = clamp(atlas_coords.y + 1, base_y, max_y)
			var new_atlas_x: int = clamp(atlas_coords.x, 0, 2)
			
			# Save this updated tile coordinate configuration to apply cleanly
			pending_changes[cell] = {
				"source_id": source_id,
				"coords": Vector2i(new_atlas_x, new_atlas_y),
				"alternative_tile": alternative_tile
			}

	# 4. Safely flush all pending tile calculations to the layer map simultaneously
	for target_cell in pending_changes:
		var data: Dictionary = pending_changes[target_cell]
		set_cell(target_cell, data["source_id"], data["coords"], data["alternative_tile"])
