extends Node

var party: Array[String] = ["Aria"]
var party_gold: int = 0
var party_experience: int = 0
var player_stats := {
	"hp": 120,
	"max_hp": 120,
	"mp": 40,
	"max_mp": 40,
	"level": 1,
	"experience": 0,
	"attack": 12,
	"defense": 10,
	"magic": 15,
	"speed": 11
}

var corruption_level: int = 0
var corruption_stage: int = 0
var corruption_days_remaining: int = 7
var hero_captured: bool = false
var consecutive_companion_defeats: int = 0
var companionless_defeats: int = 0
var escape_defeats: int = 0

var world_progress := {
	"current_scene": "",
	"visited_areas": [],
	"opened_chests": [],
	"completed_events": []
}

var companions = {
	"Elara": {"recruited": false, "bond": 0, "captured": false, "corruption_stage": 0},
	"Lyra": {"recruited": false, "bond": 0, "captured": false, "corruption_stage": 0},
	"Selene": {"recruited": false, "bond": 0, "captured": false, "corruption_stage": 0},
	"Vivienne": {"recruited": false, "bond": 0, "captured": false, "corruption_stage": 0},
	"Freya": {"recruited": false, "bond": 0, "captured": false, "corruption_stage": 0}
}

func reset_new_game() -> void:
	party = ["Aria"]
	party_gold = 0
	party_experience = 0
	corruption_level = 0
	corruption_stage = 0
	corruption_days_remaining = 7
	hero_captured = false
	consecutive_companion_defeats = 0
	companionless_defeats = 0
	escape_defeats = 0
	world_progress = {
		"current_scene": "",
		"visited_areas": [],
		"opened_chests": [],
		"completed_events": []
	}
	for companion_name in companions:
		companions[companion_name]["recruited"] = false
		companions[companion_name]["bond"] = 0
		companions[companion_name]["captured"] = false
		companions[companion_name]["corruption_stage"] = 0

func recruit_companion(companion_name: String) -> void:
	if not companions.has(companion_name):
		return
	companions[companion_name]["recruited"] = true
	if not party.has(companion_name):
		party.append(companion_name)
	if SaveManager.is_node_ready():
		SaveManager.save_game()

func get_party_member(character_id: String) -> CharacterData:
	var character_path := "res://data/characters/" + character_id.to_lower() + ".tres"
	if ResourceLoader.exists(character_path):
		return load(character_path)
	return null

func get_party_members() -> Array[CharacterData]:
	var members: Array[CharacterData] = []
	for character_id in party:
		var character := get_party_member(character_id)
		if character != null:
			members.append(character)
	return members

func mark_area_visited(area_name: String) -> void:
	if not world_progress.visited_areas.has(area_name):
		world_progress.visited_areas.append(area_name)
		SaveManager.save_game()

func record_chest_open(chest_id: String) -> void:
	if chest_id.is_empty():
		return
	if not world_progress.opened_chests.has(chest_id):
		world_progress.opened_chests.append(chest_id)
		SaveManager.save_game()

func is_chest_open(chest_id: String) -> bool:
	return not chest_id.is_empty() and world_progress.opened_chests.has(chest_id)

func record_completed_event(event_id: String) -> void:
	if event_id.is_empty():
		return
	if not world_progress.completed_events.has(event_id):
		world_progress.completed_events.append(event_id)
		SaveManager.save_game()
