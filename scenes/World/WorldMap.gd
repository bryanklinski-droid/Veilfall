extends Node2D

const GREYHAVEN_DRESSING := preload("res://scenes/World/greyhaven_dressing.gd")
const GREYHAVEN_LANDMARK := preload("res://scenes/World/greyhaven_landmark.gd")
const GREYHAVEN_REFERENCE_OVERHAUL := preload("res://scenes/World/greyhaven_reference_overhaul.gd")

func _ready() -> void:
	GameState.world_progress.current_scene = "res://scenes/World/WorldMap.tscn"
	mark_area_visited("WorldMap")
	_add_environment_dressing()
	_add_landmark_layer()
	_add_reference_overhaul()
	_clear_cottage_tree_overlap()
	_add_cottage_world_collision()
	SaveManager.save_game()

func _add_environment_dressing() -> void:
	if has_node("GreyhavenDressing"):
		return
	var dressing := Node2D.new()
	dressing.name = "GreyhavenDressing"
	dressing.set_script(GREYHAVEN_DRESSING)
	add_child(dressing)
	move_child(dressing, 1)

func _add_landmark_layer() -> void:
	if has_node("GreyhavenLandmark"):
		return
	var landmark := Node2D.new()
	landmark.name = "GreyhavenLandmark"
	landmark.set_script(GREYHAVEN_LANDMARK)
	add_child(landmark)
	move_child(landmark, 2)

func _add_reference_overhaul() -> void:
	if has_node("GreyhavenReferenceOverhaul"):
		return
	var overhaul := Node2D.new()
	overhaul.name = "GreyhavenReferenceOverhaul"
	overhaul.set_script(GREYHAVEN_REFERENCE_OVERHAUL)
	add_child(overhaul)
	move_child(overhaul, 3)

func _clear_cottage_tree_overlap() -> void:
	for path in [
		"Environment/Vegetation/T4",
		"Environment/Vegetation/T17",
		"Environment/Vegetation/T18"
	]:
		var tree := get_node_or_null(path)
		if tree != null:
			tree.visible = false

	var dressing := get_node_or_null("GreyhavenDressing")
	if dressing != null:
		var clearing := Rect2(Vector2(390, 245), Vector2(350, 320))
		for child in dressing.get_children():
			if child is Sprite2D:
				var sprite := child as Sprite2D
				if sprite.texture != null and sprite.texture.resource_path.ends_with("greyhaven_pine.svg"):
					if clearing.has_point(sprite.position):
						sprite.visible = false

func _add_cottage_world_collision() -> void:
	var collision_root := get_node_or_null("Collision")
	if collision_root == null or collision_root.has_node("CottageBody"):
		return

	var body := StaticBody2D.new()
	body.name = "CottageBody"
	body.collision_layer = 1
	body.collision_mask = 1
	collision_root.add_child(body)

	_add_cottage_shape(body, Vector2(555, 455), Vector2(300, 160))
	_add_cottage_shape(body, Vector2(452, 535), Vector2(92, 26))
	_add_cottage_shape(body, Vector2(658, 535), Vector2(92, 26))

func _add_cottage_shape(body: StaticBody2D, world_pos: Vector2, size: Vector2) -> void:
	var shape_node := CollisionShape2D.new()
	shape_node.position = world_pos
	var rect := RectangleShape2D.new()
	rect.size = size
	shape_node.shape = rect
	body.add_child(shape_node)

func mark_area_visited(area_name: String) -> void:
	if not GameState.world_progress.visited_areas.has(area_name):
		GameState.world_progress.visited_areas.append(area_name)
		SaveManager.save_game()

func record_chest_open(chest_id: String) -> void:
	if chest_id == "":
		return

	if not GameState.world_progress.opened_chests.has(chest_id):
		GameState.world_progress.opened_chests.append(chest_id)
		SaveManager.save_game()

func change_scene(scene_path: String) -> void:
	GameState.world_progress.current_scene = scene_path
	SaveManager.save_game()
	get_tree().change_scene_to_file(scene_path)