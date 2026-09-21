class_name Crate
extends RigidBody2D

@export var current_stage: int = 3
@export var tile_size: Vector2i = Vector2i(64, 64)
@export var decay_distance: float = 700.0
@export var stage_speed_thresholds: Dictionary = {
	3: 250.0,
	2: 150.0,
	1: 75.0
}

# Standard Grid mapping:
# Stage 3 -> (0, 1) | Stage 2 -> (1, 0) | Stage 1 -> (1, 1)
var stage_grid_coords: Dictionary = {
	3: Vector2i(0, 1),
	2: Vector2i(1, 0),
	1: Vector2i(1, 1)
}

@onready var sprite: Sprite2D = $Sprite2D
@onready var particles: GPUParticles2D = $WoodParticles


func _ready() -> void:
	add_to_group("Crates")

	if sprite:
		sprite.region_enabled = true

	if tile_size.x <= 0 or tile_size.y <= 0:
		tile_size = Vector2i(16, 16)

	update_texture()


func on_season_changed() -> void:
	var player = get_tree().get_first_node_in_group("player")

	# If there is no player, don't decay
	if player == null:
		return

	# Don't decay if the crate is too far away from the player
	if global_position.distance_to(player.global_position) > decay_distance:
		return

	var mat = sprite.material as ShaderMaterial

	if current_stage == 3:
		if mat:
			var tween = create_tween()
			tween.tween_property(mat, "shader_parameter/age_progress", 1.0, 2.0)
			await tween.finished
			
			mat.set_shader_parameter("age_progress", 0.0)

		current_stage = 1
		if sprite and sprite.texture:
			sprite.region_rect = Rect2(0, 0, tile_size.x, tile_size.y)

	else:
		if mat:
			var tween = create_tween().set_parallel(true)
			tween.tween_property(mat, "shader_parameter/age_progress", 1.0, 2.0)
			tween.tween_property(sprite, "modulate:a", 0.0, 2.0)
			await tween.finished

		queue_free()


func take_damage(impact_force: float, particle_scene: PackedScene = null) -> void:
	var required_force: float = stage_speed_thresholds.get(current_stage, 0.0)

	if impact_force < required_force:
		return

	current_stage -= 1

	if current_stage <= 0:
		explode()
	else:
		if particles:
			particles.restart()
		update_texture()


func update_texture() -> void:
	if sprite == null or sprite.texture == null:
		return

	if stage_grid_coords.has(current_stage):
		var grid_pos: Vector2i = stage_grid_coords[current_stage]
		
		sprite.region_rect = Rect2(
			grid_pos.x * tile_size.x,
			grid_pos.y * tile_size.y,
			tile_size.x,
			tile_size.y
		)


func explode() -> void:
	queue_free()
