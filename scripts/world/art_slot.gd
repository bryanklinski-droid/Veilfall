class_name ArtSlot
extends Node2D

## Production-art adapter used by world scenes.
## Gameplay nodes never need to know whether a final texture has arrived yet.

@export_file("*.png", "*.webp", "*.svg") var production_texture_path := ""
@export var fallback_node_path: NodePath
@export var texture_scale := Vector2.ONE
@export var texture_offset := Vector2.ZERO
@export var centered := true

var _production_sprite: Sprite2D

func _ready() -> void:
	_refresh_visual()

func _refresh_visual() -> void:
	if production_texture_path.is_empty() or not ResourceLoader.exists(production_texture_path):
		_set_fallback_visible(true)
		return

	var texture := load(production_texture_path) as Texture2D
	if texture == null:
		_set_fallback_visible(true)
		return

	_production_sprite = Sprite2D.new()
	_production_sprite.name = "ProductionArt"
	_production_sprite.texture = texture
	_production_sprite.centered = centered
	_production_sprite.position = texture_offset
	_production_sprite.scale = texture_scale
	add_child(_production_sprite)
	_set_fallback_visible(false)

func _set_fallback_visible(value: bool) -> void:
	if fallback_node_path.is_empty():
		return
	var fallback := get_node_or_null(fallback_node_path) as CanvasItem
	if fallback != null:
		fallback.visible = value
