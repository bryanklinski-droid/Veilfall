extends Node2D

const GREYHAVEN_LANDMARK := preload("res://scenes/World/greyhaven_landmark.gd")
const GREYHAVEN_REFERENCE_OVERHAUL := preload("res://scenes/World/greyhaven_reference_overhaul.gd")

func _ready() -> void:
	GameState.world_progress.current_scene = "res://scenes/World/WorldMap.tscn"
	mark_area_visited("WorldMap")
	_prepare_reference_composition()
	_add_landmark_layer()
	_add_reference_overhaul()
	_add_cottage_world_collision()
	SaveManager.save_game()

func _prepare_reference_composition() -> void:
	# Retire the prototype dressing and the oversized legacy east-side ruin/corruption.
	# The base terrain and road remain as the gameplay floor while the focused art layers
	# below rebuild Greyhaven around the cottage -> road -> board -> corrupted ruin flow.
	for path in [
		"Environment/Corruption",
		"Environment/Structures"
	]:
		var node := get_node_or_null(path)
		if node != null:
			node.visible = false

	# The old broad forest-mass polygons read as giant geometric wedges underneath the
	# new composition. Keep the actual ground shader but remove these prototype overlays.
	for path in [
		"Environment/Terrain/NorthForestMass",
		"Environment/Terrain/SouthForestMass",
		"Environment/Terrain/EastForestMass"
	]:
		var node := get_node_or_null(path)
		if node != null:
			node.visible = false

	# Clear legacy trees from the cottage and the new eastern landmark corridor. Trees
	# outside these zones remain as distant/foreground framing.
	var vegetation := get_node_or_null("Environment/Vegetation")
	if vegetation != null:
		var cottage_clear := Rect2(Vector2(210, 190), Vector2(690, 520))
		var east_clear := Rect2(Vector2(1260, 150), Vector2(720, 850))
		var road_clear := Rect2(Vector2(820, 250), Vector2(360, 980))
		for child in vegetation.get_children():
			if child is Node2D:
				var item := child as Node2D
				if cottage_clear.has_point(item.position) or east_clear.has_point(item.position) or road_clear.has_point(item.position):
					item.visible = false

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