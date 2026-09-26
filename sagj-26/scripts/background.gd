extends Node2D

@export_category("Sprite Layers (0: Spring, 1: Summer, 2: Autumn, 3: Winter)")
@export var sky_sprites: Array[Sprite2D] = []
@export var parallax_cloud_sprites: Array[Sprite2D] = []
@export var large_cloud_sprites: Array[Sprite2D] = []


func _ready() -> void:
	# Forces the background to cleanly reset back to the active season upon entering the level
	var initial_active_index: int = clampi(Global.season, 0, 3)
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
	
	var active_from_index: int = clampi(Global.season, 0, 3)
	var active_to_index: int = active_from_index
	var blend_factor: float = 0.0

	# Check if the player is actively transitioning seasons
	if player and "changing_season" in player and player.changing_season:
		active_from_index = clampi(player.start_season, 0, 3)
		active_to_index = clampi(player.target_season, 0, 3)
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
