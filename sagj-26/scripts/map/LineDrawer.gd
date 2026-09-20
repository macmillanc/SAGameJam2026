extends Node2D

@export var levels_container: Node2D

@export_group("Line Styling")
@export var line_color: Color = Color(1.0, 1.0, 1.0, 0.8)
@export var line_width: float = 8.0
@export var dash_length: float = 24.0
@export var gap_length: float = 16.0

# Center of 256x256 pixel button
const NODE_CENTER_OFFSET: Vector2 = Vector2(128, 128)

func _ready() -> void:
	queue_redraw()

func redraw_connections() -> void:
	queue_redraw()

func _draw() -> void:
	if not levels_container:
		return

	# Find all visible CanvasItems (Control / TextureButton inside Node2D)
	var unlocked_nodes: Array[CanvasItem] = []
	for child in levels_container.get_children():
		if child is CanvasItem and child.visible:
			unlocked_nodes.append(child)

	if unlocked_nodes.size() < 2:
		return

	# Draw lines between sequential unlocked levels
	for i in range(unlocked_nodes.size() - 1):
		var node_a = unlocked_nodes[i]
		var node_b = unlocked_nodes[i + 1]

		var start_pos: Vector2 = to_local(node_a.global_position + NODE_CENTER_OFFSET)
		var end_pos: Vector2 = to_local(node_b.global_position + NODE_CENTER_OFFSET)

		_draw_dashed_line(start_pos, end_pos)

func _draw_dashed_line(from: Vector2, to: Vector2) -> void:
	var total_distance: float = from.distance_to(to)
	var direction: Vector2 = (to - from).normalized()
	var current_distance: float = 0.0

	while current_distance < total_distance:
		var dash_end_dist: float = min(current_distance + dash_length, total_distance)
		
		var dash_start: Vector2 = from + direction * current_distance
		var dash_end: Vector2 = from + direction * dash_end_dist

		draw_line(dash_start, dash_end, line_color, line_width, true)
		current_distance += dash_length + gap_length
