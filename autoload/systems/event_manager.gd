extends Node

## Manages game events, quests, and story progression flags

signal event_triggered(event_id: String)
signal quest_started(quest_id: String, quest_data: Dictionary)
signal quest_advanced(quest_id: String, stage: int)
signal quest_completed(quest_id: String, rewards: Dictionary)

var event_flags: Dictionary = {}
var quest_flags: Dictionary = {}
var quests: Dictionary = {}
var completed_quests: Array = []
var dialogue_history: Array = []

func _ready() -> void:
	load_quest_database()

## Set an event flag (quest started, cutscene watched, etc.)
func set_event_flag(event_id: String, value: bool = true) -> void:
	event_flags[event_id] = value
	event_triggered.emit(event_id)
	SaveManager.save_game()

func is_event_flagged(event_id: String) -> bool:
	return event_flags.get(event_id, false)

## Set quest flag (legacy support)
func set_quest_flag(quest_id: String, value: bool = true) -> void:
	quest_flags[quest_id] = value
	SaveManager.save_game()

## Start a quest
func start_quest(quest_id: String) -> bool:
	if completed_quests.has(quest_id):
		return false  # Already completed
	
	if not quests.has(quest_id):
		quests[quest_id] = {
			"started": true,
			"stage": 0,
			"completed": false,
			"start_time": Time.get_ticks_msec()
		}
		quest_started.emit(quest_id, quests[quest_id])
		set_event_flag("quest_" + quest_id + "_started")
		SaveManager.save_game()
		return true
	
	return false

## Advance quest stage
func advance_quest_stage(quest_id: String) -> int:
	if not quests.has(quest_id):
		return -1
	
	quests[quest_id]["stage"] += 1
	quest_advanced.emit(quest_id, quests[quest_id]["stage"])
	SaveManager.save_game()
	return quests[quest_id]["stage"]

## Complete a quest (legacy support + new system)
func complete_quest(quest_id: String, rewards: Dictionary = {}) -> bool:
	if completed_quests.has(quest_id):
		return false
	
	completed_quests.append(quest_id)
	quest_flags[quest_id] = true
	
	if quests.has(quest_id):
		quests[quest_id]["completed"] = true
		quests[quest_id]["completed_time"] = Time.get_ticks_msec()
	
	# Apply rewards
	if "experience" in rewards:
		GameState.party_experience = GameState.party_experience + rewards["experience"]
	if "gold" in rewards:
		GameState.party_gold = GameState.party_gold + rewards["gold"]
	if "items" in rewards:
		for item_id in rewards["items"]:
			InventoryManager.add_item(item_id, rewards["items"][item_id])
	
	quest_completed.emit(quest_id, rewards)
	set_event_flag("quest_" + quest_id + "_completed")
	SaveManager.save_game()
	
	return true

## Get quest stage
func get_quest_stage(quest_id: String) -> int:
	if quests.has(quest_id):
		return quests[quest_id]["stage"]
	return -1

func is_quest_active(quest_id: String) -> bool:
	return quests.has(quest_id) and quests[quest_id]["started"] and not quests[quest_id]["completed"]

func is_quest_completed(quest_id: String) -> bool:
	return completed_quests.has(quest_id)

## Load quest database
func load_quest_database() -> void:
	var example_quests = {
		"find_elara": {
			"title": "Find Elara",
			"description": "Search for Elara in the forest",
			"stages": 3,
			"rewards": {"experience": 250, "gold": 100}
		},
		"defeat_bandits": {
			"title": "Defeat the Bandits",
			"description": "Clear out the bandit camp",
			"stages": 2,
			"rewards": {"experience": 500, "gold": 250}
		},
		"save_lyra": {
			"title": "Save Lyra from Corruption",
			"description": "Lyra has fallen to corruption - save her",
			"stages": 4,
			"rewards": {"experience": 1000, "gold": 500}
		}
	}
	
	for quest_id in example_quests:
		if not quests.has(quest_id):
			quests[quest_id] = example_quests[quest_id]
			quests[quest_id]["started"] = false
			quests[quest_id]["completed"] = false

## Get all active quests
func get_active_quests() -> Array[String]:
	var active = []
	for quest_id in quests:
		if is_quest_active(quest_id):
			active.append(quest_id)
	return active

## Get all available quests (not started)
func get_available_quests() -> Array[String]:
	var available = []
	for quest_id in quests:
		if not is_quest_active(quest_id) and not is_quest_completed(quest_id):
			available.append(quest_id)
	return available

## Get completed quests
func get_completed_quests() -> Array[String]:
	return completed_quests.duplicate()

## Get quest info
func get_quest_info(quest_id: String) -> Dictionary:
	if quests.has(quest_id):
		return quests[quest_id].duplicate()
	return {}

## Get quest count by status
func get_quest_count() -> Dictionary:
	return {
		"active": get_active_quests().size(),
		"available": get_available_quests().size(),
		"completed": completed_quests.size(),
		"total": quests.size()
	}

## Recruit companion through event
func recruit_companion_event(companion_name: String, context: String = "") -> void:
	GameState.recruit_companion(companion_name)
	set_event_flag("companion_" + companion_name + "_recruited")
	print("Recruited: %s (%s)" % [companion_name, context])

## Log dialogue (for dialogue system)
func log_dialogue(speaker: String, text: String) -> void:
	dialogue_history.append({
		"speaker": speaker,
		"text": text,
		"timestamp": Time.get_ticks_msec()
	})
