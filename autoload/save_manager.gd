extends Node

const SAVE_PATH := "user://veilfall_save.json"

func save_game() -> bool:
	var save_data := {
		"version": 3,
		"game_state": {
			"party": GameState.party,
			"companions": GameState.companions,
			"corruption_stage": GameState.corruption_stage,
			"corruption_days_remaining": GameState.corruption_days_remaining,
			"escape_defeats": GameState.escape_defeats,
			"companionless_defeats": GameState.companionless_defeats,
			"consecutive_companion_defeats": GameState.consecutive_companion_defeats,
			"hero_captured": GameState.hero_captured
		},
		"inventory": InventoryManager.items,
		"events": {
			"completed": EventManager.completed_events,
			"active": EventManager.active_event_id
		}
	}

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Unable to open save file for writing.")
		return false

	file.store_string(JSON.stringify(save_data))
	file.close()
	return true

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("Unable to open save file for reading.")
		return false

	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if not (parsed is Dictionary):
		push_error("Save file contains invalid data.")
		return false

	var game_state_data = parsed.get("game_state", {})
	var inventory_data = parsed.get("inventory", {})
	if not (game_state_data is Dictionary) or not (inventory_data is Dictionary):
		push_error("Save file is missing required sections.")
		return false

	GameState.party.clear()
	var saved_party = game_state_data.get("party", ["Aria"])
	if saved_party is Array:
		for member in saved_party:
			GameState.party.append(str(member))
	if GameState.party.is_empty():
		GameState.party.append("Aria")

	GameState.corruption_stage = clampi(int(game_state_data.get("corruption_stage", 0)), 0, CorruptionManager.MAX_CORRUPTION_STAGE)
	GameState.corruption_days_remaining = maxi(int(game_state_data.get("corruption_days_remaining", 0)), 0)
	GameState.escape_defeats = maxi(int(game_state_data.get("escape_defeats", 0)), 0)
	GameState.companionless_defeats = maxi(int(game_state_data.get("companionless_defeats", 0)), 0)
	GameState.consecutive_companion_defeats = maxi(int(game_state_data.get("consecutive_companion_defeats", 0)), 0)
	GameState.hero_captured = bool(game_state_data.get("hero_captured", false))

	var saved_companions = game_state_data.get("companions", {})
	if saved_companions is Dictionary:
		for name in GameState.companions:
			if saved_companions.has(name) and saved_companions[name] is Dictionary:
				GameState.companions[name] = saved_companions[name]

	InventoryManager.clear_inventory()
	for item_id in inventory_data:
		var amount := int(inventory_data[item_id])
		if amount > 0:
			InventoryManager.items[str(item_id)] = amount

	var event_data = parsed.get("events", {})
	EventManager.reset_events()
	if event_data is Dictionary:
		var completed = event_data.get("completed", {})
		if completed is Dictionary:
			EventManager.completed_events = completed
		EventManager.active_event_id = str(event_data.get("active", ""))

	return true

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
