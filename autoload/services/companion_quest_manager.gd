
extends Node

signal companion_quest_started(character_id: String, quest_id: String)
signal companion_quest_stage_advanced(character_id: String, quest_id: String, stage: int)
signal companion_quest_completed(character_id: String, quest_id: String)

var companion_quests: Dictionary = {}  # {character_id: {quest_id: QuestData}}
var active_companion_quests: Dictionary = {}  # {character_id: current_quest_id}

func _ready() -> void:
	load_companion_quests()

## Load all companion quests from data directory
func load_companion_quests() -> void:
	var dir = DirAccess.open("res://data/quests/companion/")
	if dir:
		dir.list_dir_begin()
		var filename = dir.get_next()
		while filename != "":
			if filename.ends_with(".tres"):
				var quest = load("res://data/quests/companion/" + filename)
				if quest is QuestData:
					# Quest ID format: "character_id_questname"
					var parts = quest.quest_id.split("_")
					if parts.size() >= 2:
						var character_id = parts[0]
						if not companion_quests.has(character_id):
							companion_quests[character_id] = {}
							active_companion_quests[character_id] = ""
						companion_quests[character_id][quest.quest_id] = quest
			filename = dir.get_next()
	
	print("Loaded %d companion quests" % companion_quests.size())

## Get all quests for a companion
func get_companion_quests(character_id: String) -> Array[QuestData]:
	var quests = []
	if companion_quests.has(character_id):
		for quest_id in companion_quests[character_id]:
			quests.append(companion_quests[character_id][quest_id])
	return quests

## Start a companion quest
func start_companion_quest(character_id: String, quest_id: String) -> bool:
	if not companion_quests.has(character_id):
		return false
	if not companion_quests[character_id].has(quest_id):
		return false
	
	var quest = companion_quests[character_id][quest_id]
	quest.is_active = true
	quest.add_log_entry("Quest started")
	active_companion_quests[character_id] = quest_id
	
	companion_quest_started.emit(character_id, quest_id)
	print("Started companion quest: %s for %s" % [quest_id, character_id])
	SaveManager.save_game()
	return true

## Advance companion quest stage
func advance_companion_quest_stage(character_id: String, quest_id: String) -> bool:
	if not companion_quests.has(character_id):
		return false
	if not companion_quests[character_id].has(quest_id):
		return false
	
	var quest = companion_quests[character_id][quest_id]
	if quest.advance_stage():
		var stage = quest.get_current_stage()
		if stage:
			quest.add_log_entry("Advanced to stage: %s" % stage.objective)
		companion_quest_stage_advanced.emit(character_id, quest_id, quest.current_stage)
		SaveManager.save_game()
		return true
	
	return false

## Complete companion quest
func complete_companion_quest(character_id: String, quest_id: String) -> bool:
	if not companion_quests.has(character_id):
		return false
	if not companion_quests[character_id].has(quest_id):
		return false
	
	var quest = companion_quests[character_id][quest_id]
	quest.is_completed = true
	quest.is_active = false
	quest.add_log_entry("Quest completed!")
	active_companion_quests[character_id] = ""
	
	# Grant bond increase on quest completion
	BondManager.increase_bond(character_id, 50)
	
	# Grant rewards
	GameState.party_gold += quest.rewards.get("gold", 0)
	GameState.party_experience += quest.rewards.get("experience", 0)
	
	companion_quest_completed.emit(character_id, quest_id)
	print("Completed companion quest: %s for %s" % [quest_id, character_id])
	SaveManager.save_game()
	return true

## Get current active quest for companion
func get_active_companion_quest(character_id: String) -> QuestData:
	var quest_id = active_companion_quests.get(character_id, "")
	if quest_id and companion_quests.has(character_id):
		return companion_quests[character_id].get(quest_id)
	return null

## Check if companion has completed a quest
func is_companion_quest_completed(character_id: String, quest_id: String) -> bool:
	if companion_quests.has(character_id):
		var quest = companion_quests[character_id].get(quest_id)
		if quest:
			return quest.is_completed
	return false

## Get completed quests for companion (for storyline progression)
func get_completed_companion_quests(character_id: String) -> Array[QuestData]:
	var completed = []
	if companion_quests.has(character_id):
		for quest_id in companion_quests[character_id]:
			var quest = companion_quests[character_id][quest_id]
			if quest.is_completed:
				completed.append(quest)
	return completed

## Get next available quest for companion
func get_next_companion_quest(character_id: String) -> QuestData:
	if companion_quests.has(character_id):
		for quest_id in companion_quests[character_id]:
			var quest = companion_quests[character_id][quest_id]
			if not quest.is_active and not quest.is_completed:
				return quest
	return null
