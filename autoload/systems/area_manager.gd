extends Node

signal area_changed(area: AreaData)
signal enemy_encountered(enemies: Array[CharacterData])
signal treasure_found(treasure: Dictionary)

var current_area: AreaData = null
var visited_areas: Array[String] = []
var area_database: Dictionary = {}

func _ready() -> void:
	load_area_database()

## Load all areas from data directory
func load_area_database() -> void:
	var dir = DirAccess.open("res://data/areas/")
	if dir:
		dir.list_dir_begin()
		var filename = dir.get_next()
		while filename != "":
			if filename.ends_with(".tres"):
				var area_id = filename.trim_suffix(".tres")
				var area = load("res://data/areas/" + filename)
				if area is AreaData:
					area_database[area_id] = area
			filename = dir.get_next()
	
	print("Loaded %d areas" % area_database.size())

## Enter an area
func enter_area(area_id: String) -> bool:
	if not area_database.has(area_id):
		print("Error: Area not found: ", area_id)
		return false
	
	var area = area_database[area_id]
	current_area = area
	
	if not visited_areas.has(area_id):
		visited_areas.append(area_id)
		EventManager.set_event_flag("visited_" + area_id)
	
	# Load area scene if exists
	if area.scene_path and ResourceLoader.exists(area.scene_path):
		get_tree().change_scene_to_file(area.scene_path)
	
	# Play area music if exists
	if area.music_path:
		AudioManager.play_music(area.music_path)
	
	area_changed.emit(area)
	print("Entered area: ", area.area_name)
	return true

## Transition to connected area
func travel_to_connected_area(area_id: String) -> bool:
	if not current_area or not current_area.connected_areas.has(area_id):
		print("Error: Cannot travel to ", area_id)
		return false
	
	return enter_area(area_id)

## Random encounter in current area
func trigger_random_encounter() -> void:
	if not current_area or current_area.enemies.is_empty():
		return
	
	var enemies = current_area.get_encounter_enemies(randi_range(1, 3))
	if not enemies.is_empty():
		enemy_encountered.emit(enemies)
		# Battle will be triggered by caller

## Find treasure chest in current area
func find_treasure(chest_index: int = 0) -> Dictionary:
	if not current_area or chest_index >= current_area.treasure_chests.size():
		return {}
	
	var treasure = current_area.treasure_chests[chest_index]
	treasure_found.emit(treasure)
	return treasure

## Get current area info
func get_current_area_info() -> Dictionary:
	if not current_area:
		return {}
	
	return {
		"id": current_area.area_id,
		"name": current_area.area_name,
		"description": current_area.description,
		"difficulty": current_area.difficulty_level,
		"is_dungeon": current_area.is_dungeon
	}

## Get path between two areas (for mini-map)
func get_area_connections() -> Dictionary:
	var connections = {}
	for area_id in area_database:
		var area = area_database[area_id]
		connections[area_id] = area.get_connected_areas()
	return connections

## Check if area has been visited
func is_area_visited(area_id: String) -> bool:
	return visited_areas.has(area_id)

## Get all visited areas
func get_visited_areas() -> Array[String]:
	return visited_areas.duplicate()
