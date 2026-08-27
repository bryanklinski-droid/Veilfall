extends Node

var potions = 0
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
var world_progress := {
	"current_scene": "",
	"visited_areas": [],
	"opened_chests": [],
	"completed_events": []
}
var companions = {
	"Elara": {
		"recruited": false,
		"bond": 0,
		"captured": false,
		"corruption_stage": 0
	},
	"Lyra": {
		"recruited": false,
		"bond": 0,
		"captured": false,
		"corruption_stage": 0
	},
	"Selene": {
		"recruited": false,
		"bond": 0,
		"captured": false,
		"corruption_stage": 0
	},
	"Vivienne": {
		"recruited": false,
		"bond": 0,
		"captured": false,
		"corruption_stage": 0
	},
	"Freya": {
		"recruited": false,
		"bond": 0,
		"captured": false,
		"corruption_stage": 0
	}
}

func recruit_companion(companion_name: String) -> void:
	if companions.has(companion_name):companions[companion_name]["recruited"] = true

	if not party.has(companion_name):
		party.append(companion_name)

	SaveManager.save_game()

## Get party member character data by ID
func get_party_member(character_id: String) -> CharacterData:
	var character_path = "res://data/characters/" + character_id.to_lower() + ".tres"
	if ResourceLoader.exists(character_path):
		return load(character_path)
	return null

## Get all party members' character data
func get_party_members() -> Array[CharacterData]:
	var members = []
	for character_id in party:
		var character = get_party_member(character_id)
		if character:
			members.append(character)
	return members

func mark_area_visited(area_name: String) -> void:
	if not world_progress.visited_areas.has(area_name):
		world_progress.visited_areas.append(area_name)
		SaveManager.save_game()

func record_chest_open(chest_id: String) -> void:
	if chest_id == "":
		return

	if not world_progress.opened_chests.has(chest_id):
		world_progress.opened_chests.append(chest_id)
		SaveManager.save_game()

func record_completed_event(event_id: String) -> void:
	if event_id == "":
		return

	if not world_progress.completed_events.has(event_id):
		world_progress.completed_events.append(event_id)
		SaveManager.save_game()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Companions are recruited through gameplay, quests, and cutscenes


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
