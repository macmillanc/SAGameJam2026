extends Node2D

@export var sky_sprites: Array[Sprite2D] = []
@export var parallax_cloud_sprites: Array[Sprite2D] = []
@export var large_cloud_sprites: Array[Sprite2D] = []

# Map Global.season to Inspector indices (0=Sky1, 1=Sky2, 6=Sky7, 7=Sky8)
var season_texture_map: Dictionary = {
	0: 0, # Spring -> Sky 1 (Index 0)
	1: 1, # Summer -> Sky 2 (Index 1)
	2: 6, # Autumn -> Sky 7 (Index 6)
	3: 7  # Winter -> Sky 8 (Index 7)
}


func _ready() -> void:
	# Forces the background to cleanly reset back to the current active season upon entering the level
	var initial_active_index: int = season_texture_map.get(Global.season, 0)
	
	var total_layers: int = max(
		sky_sprites.size(), 
		max(parallax_cloud_sprites.size(), large_cloud_sprites.size())
	)
	
	# Explicitly loop through all sprites on load frame and clear alpha artifacts
	for i in range(total_layers):
		var target_alpha: float = 1.0 if i == initial_active_index else 0.0
		
		_set_layer_alpha(sky_sprites, i, target_alpha)
		_set_layer_alpha(parallax_cloud_sprites, i, target_alpha)
		_set_layer_alpha(large_cloud_sprites, i, target_alpha)


func _process(_delta: float) -> void:
	var player: Node = get_tree().get_first_node_in_group("player")
	
	var active_from_index: int = season_texture_map.get(Global.season, 0)
	var active_to_index: int = active_from_index
	var blend_factor: float = 0.0

	# Check if the player is actively transitioning seasons
	if player and "changing_season" in player and player.changing_season:
		active_from_index = season_texture_map.get(player.start_season, 0)
		active_to_index = season_texture_map.get(player.target_season, 0)
		blend_factor = player.season_transition_progress

	var total_layers: int = max(
		sky_sprites.size(), 
		max(parallax_cloud_sprites.size(), large_cloud_sprites.size())
	)

	for i in range(total_layers):
		var target_alpha: float = 0.0
		
		if blend_factor > 0.0:
			# Smoothly crossfade from start season to target season
			if i == active_from_index:
				target_alpha = 1.0 - blend_factor
			elif i == active_to_index:
				target_alpha = blend_factor
		else:
			# Static state outside of transition
			if i == active_from_index:
				target_alpha = 1.0

		_set_layer_alpha(sky_sprites, i, target_alpha)
		_set_layer_alpha(parallax_cloud_sprites, i, target_alpha)
		_set_layer_alpha(large_cloud_sprites, i, target_alpha)


func _set_layer_alpha(sprite_array: Array[Sprite2D], index: int, alpha: float) -> void:
	if index < sprite_array.size() and sprite_array[index] != null:
		sprite_array[index].self_modulate.a = alpha
