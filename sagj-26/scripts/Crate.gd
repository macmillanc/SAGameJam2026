class_name Crate
extends RigidBody2D

@export var current_stage: int = 3:
	set(value):
		current_stage = value
		stage_grid_coords = {
			3: Vector2i(0, 0),
			2: Vector2i(1, 0),
			1: Vector2i(2, 0)
		}
		active_grid_pos = stage_grid_coords.get(current_stage, active_grid_pos)
		if is_node_ready():
			update_texture()

@export var tile_size: Vector2i = Vector2i(64, 64)
@export var decay_distance: float = 700.0

# Speed thresholds for the top-row damage states
@export var stage_speed_thresholds: Dictionary = {
	3: 250.0,
	2: 150.0,
	1: 75.0
}

# Uniform strength threshold for all bottom-row aged crates
@export var bottom_speed_threshold: float = 75.0

# Custom collision size for rotted crates
@export var small_collision_size: Vector2 = Vector2(32, 32)

# Adjustable vertical offset for rotted crates in the Inspector (tweak this if they float)
@export var rotted_y_offset: float = 16.0

# Top row damage states mapping (Undamaged first at 0,0):
var stage_grid_coords: Dictionary = {
	3: Vector2i(0, 0),
	2: Vector2i(1, 0),
	1: Vector2i(2, 0)
}

# Tracks the exact current texture coordinate on the 3x2 grid
var active_grid_pos: Vector2i = Vector2i(0, 0)
var normal_collision_size: Vector2 = Vector2(64, 64)

@onready var sprite: Sprite2D = $Sprite2D
@onready var particles: GPUParticles2D = $WoodParticles
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	add_to_group("Crates")

	if sprite:
		sprite.region_enabled = true

	if tile_size.x <= 0 or tile_size.y <= 0:
		tile_size = Vector2i(16, 16)

	if collision_shape and collision_shape.shape is RectangleShape2D:
		# Make the shape unique to this specific crate instance
		collision_shape.shape = collision_shape.shape.duplicate()
		normal_collision_size = collision_shape.shape.size

	# Initialize grid position based on starting stage
	active_grid_pos = stage_grid_coords.get(current_stage, Vector2i(0, 0))
	update_texture()


func on_season_changed() -> void:
	var player = get_tree().get_first_node_in_group("player")

	if player == null:
		return

	if global_position.distance_to(player.global_position) > decay_distance:
		return

	var mat = sprite.material as ShaderMaterial

	if mat:
		var tween = create_tween()
		tween.tween_property(mat, "shader_parameter/age_progress", 1.0, 2.0)
		await tween.finished
		mat.set_shader_parameter("age_progress", 0.0)

	if active_grid_pos.y == 0:
		active_grid_pos = Vector2i(active_grid_pos.x, 1)
		update_texture()
	elif active_grid_pos == Vector2i(0, 1):
		active_grid_pos = Vector2i(2, 1)
		update_texture()
	else:
		if mat:
			var fade_tween = create_tween().set_parallel(true)
			fade_tween.tween_property(mat, "shader_parameter/age_progress", 1.0, 2.0)
			fade_tween.tween_property(sprite, "modulate:a", 0.0, 2.0)
			await fade_tween.finished

		queue_free()


func take_damage(impact_force: float, _particle_scene: PackedScene = null) -> void:
	if active_grid_pos.y == 1:
		if impact_force < bottom_speed_threshold:
			return
		
		if particles:
			particles.restart()
		explode()
	else:
		var required_force: float = stage_speed_thresholds.get(current_stage, 0.0)

		if impact_force < required_force:
			return

		current_stage -= 1

		if current_stage <= 0:
			explode()
		else:
			if particles:
				particles.restart()


func update_texture() -> void:
	if sprite == null or sprite.texture == null:
		return

	sprite.region_rect = Rect2(
		active_grid_pos.x * tile_size.x,
		active_grid_pos.y * tile_size.y,
		tile_size.x,
		tile_size.y
	)

	update_collision()


func update_collision() -> void:
	if collision_shape == null or not (collision_shape.shape is RectangleShape2D):
		return

	collision_shape.disabled = false

	# Bottom row custom collision handling (all rotted crates shrink down)
	if active_grid_pos.y == 1:
		collision_shape.shape.size = small_collision_size
		# Uses the Inspector variable so you can adjust it live if needed
		collision_shape.position = Vector2(0.0, rotted_y_offset)
		set_collision_mask_value(3, true)
	else:
		# Top row crates: normal full-size collision, centered
		collision_shape.shape.size = normal_collision_size
		collision_shape.position = Vector2.ZERO
		set_collision_mask_value(3, true)

	# Force the physics body to wake up so it immediately applies the new bounds
	sleeping = false
	apply_central_impulse(Vector2(0, 1))


func explode() -> void:
	queue_free()
