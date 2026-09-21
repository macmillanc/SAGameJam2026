extends Sprite2D

@export var tree_sprites: Array[Texture2D]
var index : int = 0
var direction := 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("season_objects")
	if tree_sprites.size() > 0:
		texture = tree_sprites[index]

func update_tree():
	if tree_sprites.is_empty():
			return
	index = (index + 1) % tree_sprites.size()
	texture = tree_sprites[index]
