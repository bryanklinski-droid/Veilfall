
extends Node

signal dungeon_entered(dungeon_id: String, floor_number: int)
signal floor_changed(dungeon_id: String, floor_number: int)
signal dungeon_completed(dungeon_id: String)
signal enemy_encountered(dungeon_id: String, enemy_id: String, floor_number: int)
signal treasure_found(dungeon_id: String, treasure: Dictionary, floor_number: int)

var active_dungeon: DungeonData = null
var dungeon_progress: Dictionary = {}  # {dungeon_id: {current_floor: int, visited_floors: [int]}}
var dungeons: Dictionary = {}  # {dungeon_id: DungeonData}

func _ready() -> void:
	load_dungeons()

## Load all dungeons from data directory
func load_dungeons() -> void:
	var dir = DirAccess.open("res://data/dungeons/")
	if dir:
		dir.list_dir_begin()
		var filename = dir.get_next()
		while filename != "":
			if filename.ends_with(".tres"):
				var dungeon_id = filename.trim_suffix(".tres")
				var dungeon = load("res://data/dungeons/" + filename)
				if dungeon is DungeonData:
					dungeons[dungeon_id] = dungeon
					dungeon_progress[dungeon_id] = {
						"current_floor": 0,
						"visited_floors": [],
						"completed": false
					}
			filename = dir.get_next()
	
	print("Loaded %d dungeons" % dungeons.size())

## Enter a dungeon
func enter_dungeon(dungeon_id: String) -> bool:
	if not dungeons.has(dungeon_id):
		print("Dungeon not found: ", dungeon_id)
		return false
	
	active_dungeon = dungeons[dungeon_id]
	var progress = dungeon_progress[dungeon_id]
	
	# Reset to floor 0 on new entry
	if progress.get("completed", false):
		# If completed, can revisit from start
		progress["current_floor"] = 0
	
	progress["visited_floors"].append(progress["current_floor"])
	dungeon_entered.emit(dungeon_id, progress["current_floor"])
	print("Entered dungeon: ", active_dungeon.dungeon_name)
	return true

## Advance to next floor
func advance_floor() -> bool:
	if not active_dungeon:
		return false
	
	var dungeon_id = active_dungeon.dungeon_id
	if not active_dungeon.advance_floor():
		print("Reached final floor!")
		return false
	
	var progress = dungeon_progress[dungeon_id]
	progress["current_floor"] = active_dungeon.current_floor
	progress["visited_floors"].append(active_dungeon.current_floor)
	
	floor_changed.emit(dungeon_id, active_dungeon.current_floor)
	print("Advanced to floor %d" % active_dungeon.current_floor)
	return true

## Get current floor
func get_current_floor() -> DungeonData.DungeonFloor:
	if active_dungeon:
		return active_dungeon.get_current_floor()
	return null

## Trigger random encounter on current floor
func trigger_encounter() -> String:
	if not active_dungeon:
		return ""
	
	var current_floor = active_dungeon.get_current_floor()
	if not current_floor:
		return ""
	
	var enemy_id = current_floor.get_random_encounter()
	if enemy_id:
		var dungeon_id = active_dungeon.dungeon_id
		var floor_number = active_dungeon.current_floor
		enemy_encountered.emit(dungeon_id, enemy_id, floor_number)
	
	return enemy_id

## Find treasure on current floor
func find_treasure() -> Dictionary:
	if not active_dungeon:
		return {}
	
	var current_floor = active_dungeon.get_current_floor()
	if not current_floor or current_floor.treasure_rooms.size() == 0:
		return {}
	
	var treasure = current_floor.treasure_rooms[randi() % current_floor.treasure_rooms.size()]
	treasure_found.emit(active_dungeon.dungeon_id, treasure, active_dungeon.current_floor)
	return treasure

## Complete dungeon
func complete_dungeon() -> bool:
	if not active_dungeon:
		return false
	
	var dungeon_id = active_dungeon.dungeon_id
	dungeon_progress[dungeon_id]["completed"] = true
	active_dungeon.is_completed = true
	dungeon_completed.emit(dungeon_id)
	print("Completed dungeon: ", active_dungeon.dungeon_name)
	SaveManager.save_game()
	return true

## Exit dungeon
func exit_dungeon() -> void:
	if active_dungeon:
		print("Exited dungeon: ", active_dungeon.dungeon_name)
	active_dungeon = null

## Get dungeon info
func get_dungeon_info(dungeon_id: String) -> Dictionary:
	if not dungeons.has(dungeon_id):
		return {}
	
	var dungeon = dungeons[dungeon_id]
	var progress = dungeon_progress[dungeon_id]
	
	return {
		"name": dungeon.dungeon_name,
		"description": dungeon.description,
		"floor_count": dungeon.get_floor_count(),
		"current_floor": progress["current_floor"],
		"completed": progress["completed"],
		"progress": dungeon.get_progress_percentage()
	}

## Get list of available dungeons
func get_available_dungeons() -> Array[Dictionary]:
	var available = []
	for dungeon_id in dungeons:
		var dungeon = dungeons[dungeon_id]
		available.append({
			"id": dungeon_id,
			"name": dungeon.dungeon_name,
			"description": dungeon.description,
			"floor_count": dungeon.get_floor_count()
		})
	return available

## Is dungeon active
func is_dungeon_active() -> bool:
	return active_dungeon != null
