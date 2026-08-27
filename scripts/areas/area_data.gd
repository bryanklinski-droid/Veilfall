class_name AreaData
extends Resource

@export var area_id: String = ""
@export var area_name: String = ""
@export_multiline var description: String = ""
@export var scene_path: String = ""
@export var connected_areas: Dictionary = {}  # area_id -> position/exit_name
@export var enemies: Array[CharacterData] = []
@export var treasure_chests: Array[Dictionary] = []  # {"item": String, "amount": int, "position": Vector2}
@export var npcs: Array[String] = []  # NPC dialogue IDs
@export var music_path: String = ""
@export var is_dungeon: bool = false
@export var difficulty_level: int = 1
@export var boss_enemy: CharacterData = null

## Get list of enemies that can spawn here
func get_encounter_enemies(count: int = 1) -> Array[CharacterData]:
	if enemies.is_empty():
		return []
	
	var encounter = []
	for i in range(count):
		var random_enemy = enemies[randi() % enemies.size()]
		encounter.append(random_enemy)
	
	return encounter

## Get accessible connected areas
func get_connected_areas() -> Array[String]:
	return connected_areas.keys()
