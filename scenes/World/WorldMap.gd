extends Node2D

func _ready() -> void:
	GameState.world_progress.current_scene = "res://scenes/World/WorldMap.tscn"
	mark_area_visited("WorldMap")
	SaveManager.save_game()

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
