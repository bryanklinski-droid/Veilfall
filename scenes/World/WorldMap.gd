extends Node2D

const GREYHAVEN_DRESSING := preload("res://scenes/World/greyhaven_dressing.gd")
const GREYHAVEN_LANDMARK := preload("res://scenes/World/greyhaven_landmark.gd")

func _ready() -> void:
	GameState.world_progress.current_scene = "res://scenes/World/WorldMap.tscn"
	mark_area_visited("WorldMap")
	_add_environment_dressing()
	_add_landmark_layer()
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
