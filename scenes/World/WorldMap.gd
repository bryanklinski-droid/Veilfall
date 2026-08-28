extends Node2D

const GREYHAVEN_DRESSING := preload("res://scenes/World/greyhaven_dressing.gd")
const GREYHAVEN_LANDMARK := preload("res://scenes/World/greyhaven_landmark.gd")

func _ready() -> void:
	GameState.world_progress.current_scene = "res://scenes/World/WorldMap.tscn"
	mark_area_visited("WorldMap")
	_add_environment_dressing()
	_add_landmark_layer()
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

func _clear_cottage_tree_overlap() -> void:
	# These legacy scene trees occupy the same footprint as the new cottage.
	for path in [
		"Environment/Vegetation/T4",
		"Environment/Vegetation/T17",
		"Environment/Vegetation/T18"
	]:
		var tree := get_node_or_null(path)
		if tree != null:
			tree.visible = false

	# The older procedural dressing also places pines in this footprint. Hide only
	# pines inside the cottage clearing; all other dressing remains untouched.
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
	# Put the cottage collision beside the map's normal collision bodies rather than
	# inside the visual landmark layer. This makes the house unambiguously solid.
	var collision_root := get_node_or_null("Collision")
	if collision_root == null or collision_root.has_node("CottageBody"):
		return

	var body := StaticBody2D.new()
	body.name = "CottageBody"
	body.collision_layer = 1
	body.collision_mask = 1
	collision_root.add_child(body)

	# Main building footprint. The visible house spans roughly x=404..706 and
	# y=275..535; this blocks the physical wall/facade while leaving the apron below walkable.
	_add_cottage_shape(body, Vector2(555, 455), Vector2(300, 160))
	# Foundation wings keep Aria from slipping through either lower corner while
	# preserving the centered approach to the doorstep.
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
