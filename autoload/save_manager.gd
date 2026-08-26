extends Node

const SAVE_PATH := "user://veilfall_save.json"

func save_game() -> bool:
	var save_data := {
		"version": 1,
		"game_state": {
			"potions": GameState.potions,
			"party": GameState.party,
			"companions": GameState.companions
		},
		"inventory": InventoryManager.items
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

	GameState.potions = int(game_state_data.get("potions", 0))
	GameState.party.clear()
	for member in game_state_data.get("party", ["Aria"]):
		GameState.party.append(str(member))
	if GameState.party.is_empty():
		GameState.party.append("Aria")

	var saved_companions = game_state_data.get("companions", {})
	if saved_companions is Dictionary:
		for name in GameState.companions:
			if saved_companions.has(name) and saved_companions[name] is Dictionary:
				GameState.companions[name] = saved_companions[name]

	InventoryManager.items.clear()
	for item_id in inventory_data:
		var amount := int(inventory_data[item_id])
		if amount > 0:
			InventoryManager.items[str(item_id)] = amount

	return true

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(SAVE_PATH)
