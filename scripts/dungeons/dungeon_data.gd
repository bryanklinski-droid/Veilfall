class_name DungeonData
extends Resource

@export var dungeon_id: String
@export var dungeon_name: String
@export var description: String = ""
@export var entrance_area: String  # Area ID where dungeon entrance is
@export var floors: Array = []
@export var boss_enemy_id: String = ""
@export var rewards: Dictionary = {}  # items, gold, experience bonuses

var current_floor: int = 0
var is_completed: bool = false

func get_floor(floor_number: int) -> DungeonFloor:
	if floor_number >= 0 and floor_number < floors.size():
		return floors[floor_number]
	return null

func get_current_floor() -> DungeonFloor:
	return get_floor(current_floor)

func advance_floor() -> bool:
	if current_floor < floors.size() - 1:
		current_floor += 1
		return true
	return false

func get_boss_floor() -> DungeonFloor:
	if floors.size() > 0:
		return floors[floors.size() - 1]
	return null

func get_floor_count() -> int:
	return floors.size()

func get_progress_percentage() -> float:
	if floors.size() == 0:
		return 0.0
	return (float(current_floor) / float(floors.size())) * 100.0

class DungeonFloor:
	var floor_number: int
	var area_id: String  # Area resource to load for this floor
	var floor_name: String = ""
	var difficulty: int = 1
	var enemy_encounters: Array[String] = []  # Character IDs for enemies
	var treasure_rooms: Array[Dictionary] = []  # Items on this floor
	var boss_encounter: String = ""  # Boss enemy ID, if any
	var description: String = ""
	
	func _init(p_floor_number: int, p_area_id: String, p_difficulty: int = 1) -> void:
		floor_number = p_floor_number
		area_id = p_area_id
		difficulty = p_difficulty
		floor_name = "Floor %d" % (p_floor_number + 1)
	
	func get_random_encounter() -> String:
		if enemy_encounters.size() == 0:
			return ""
		return enemy_encounters[randi() % enemy_encounters.size()]
	
	func has_boss() -> bool:
		return boss_encounter != ""
