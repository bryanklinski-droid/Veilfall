extends Node


signal defeat_event_triggered(event: DefeatEventData)
signal defeat_event_started(event: DefeatEventData)
signal defeat_event_completed(event: DefeatEventData, outcome: String)

var boss_defeat_events: Dictionary = {}  # boss_id -> DefeatEventData
var humanoid_defeat_events: Dictionary = {}  # enemy_id -> DefeatEventData
var monster_defeat_events: Dictionary = {}  # enemy_id -> DefeatEventData
var beast_defeat_events: Dictionary = {}  # enemy_id -> DefeatEventData

var current_defeat_event: DefeatEventData = null
var active_event: bool = false

func _ready() -> void:
	load_defeat_events()

func load_defeat_events() -> void:
	# Load all defeat event data from data/events/defeat_events/
	var dir = DirAccess.open("res://data/events/defeat_events/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var event_path = "res://data/events/defeat_events/" + file_name
				var event = load(event_path) as DefeatEventData
				if event:
					_categorize_event(event)
					print("Loaded defeat event: ", event.event_id)
			file_name = dir.get_next()

func _categorize_event(event: DefeatEventData) -> void:
	match event.event_type:
		"boss_defeat":
			boss_defeat_events[event.trigger_character] = event
		"humanoid_defeat":
			humanoid_defeat_events[event.trigger_character] = event
		"monster_defeat":
			monster_defeat_events[event.trigger_character] = event
		"beast_defeat":
			beast_defeat_events[event.trigger_character] = event

## Check if defeat triggers an event
func check_defeat_event(defeated_by: CharacterData, _player_party: Array[String]) -> DefeatEventData:
	if active_event:
		return null
	
	# Determine enemy type and find corresponding event
	var event = _get_defeat_event(defeated_by)
	
	if event and event.can_trigger_again():
		active_event = true
		current_defeat_event = event
		defeat_event_triggered.emit(event)
		event.mark_triggered()
		return event
	
	return null

func _get_defeat_event(enemy: CharacterData) -> DefeatEventData:
	# Check if boss
	if enemy is BossData:
		return boss_defeat_events.get(enemy.display_name, null)
	
	# Check enemy type (humanoid, monster, beast)
	var enemy_type = _determine_enemy_type(enemy)
	match enemy_type:
		"humanoid":
			return humanoid_defeat_events.get(enemy.display_name, null)
		"monster":
			return monster_defeat_events.get(enemy.display_name, null)
		"beast":
			return beast_defeat_events.get(enemy.display_name, null)
	
	return null

func _determine_enemy_type(enemy: CharacterData) -> String:
	# Infer from character name or type
	var name_lower = enemy.display_name.to_lower()
	
	if "goblin" in name_lower or "bandit" in name_lower or "criminal" in name_lower:
		return "humanoid"
	elif "wolf" in name_lower or "beast" in name_lower or "creature" in name_lower:
		return "beast"
	else:
		return "monster"

## Apply defeat event consequences to party
func apply_defeat_consequences(event: DefeatEventData) -> void:
	# Apply corruption increase
	if event.corrupts_player and event.corruption_increase > 0:
		if CorruptionManager:
			CorruptionManager.increase_corruption("hero", event.corruption_increase)
	
	# Apply stat penalties to player
	if not event.stat_penalties.is_empty():
		for stat_name in event.stat_penalties:
			if GameState.player_stats.has(stat_name):
				GameState.player_stats[stat_name] -= event.stat_penalties[stat_name]
	
	# Lose items
	for item_id in event.item_loss:
		if InventoryManager:
			InventoryManager.remove_item(item_id, 1)
	
	# Apply bond penalties to companions
	for companion_id in event.bond_changes:
		if BondManager:
			var change = event.bond_changes[companion_id]
			BondManager.decrease_bond(companion_id, abs(change))
	
	# Apply trauma effects
	for companion_id in event.trauma_effects:
		if GameState.companions.has(companion_id):
			var trauma = event.trauma_effects[companion_id]
			if not GameState.companions[companion_id].has("trauma"):
				GameState.companions[companion_id]["trauma"] = 0
			GameState.companions[companion_id]["trauma"] += trauma

## Get reward items dropped by enemy
func get_dropped_items(event: DefeatEventData) -> Array[String]:
	return event.items_dropped

## Start defeat event sequence
func start_defeat_event(event: DefeatEventData) -> void:
	defeat_event_started.emit(event)
	
	# Show initial dialogue
	if event.initial_dialogue and DialogueManager:
		DialogueManager.start_dialogue(event.initial_dialogue.dialogue_id)

## Complete defeat event (called by dialogue system)
func complete_defeat_event(outcome: String = "accepted") -> void:
	if not current_defeat_event:
		return
	
	var event = current_defeat_event
	
	# Apply consequences based on outcome
	if outcome == "accepted" or outcome == "unavoidable":
		apply_defeat_consequences(event)
	
	defeat_event_completed.emit(event, outcome)
	
	active_event = false
	current_defeat_event = null

## Get event by ID
func get_event(event_id: String) -> DefeatEventData:
	for events in [boss_defeat_events, humanoid_defeat_events, monster_defeat_events, beast_defeat_events]:
		for event in events.values():
			if event.event_id == event_id:
				return event
	return null

## Check if player is in active defeat event
func is_in_defeat_event() -> bool:
	return active_event

## Force end defeat event (for testing/escape)
func force_end_event() -> void:
	if current_defeat_event:
		complete_defeat_event("escaped")
