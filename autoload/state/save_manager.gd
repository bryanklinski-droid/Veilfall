extends Node

const SAVE_PATH := "user://savegame.json"

func _ready() -> void:
	get_tree().connect("scene_changed", Callable(self, "_on_scene_changed"))
	load_game()

func _on_scene_changed() -> void:
	# Auto-save when transitioning scenes
	save_game()

func save_game() -> void:
	var data = {
		"potions": GameState.potions,
		"party": GameState.party,
		"companions": GameState.companions,
		"inventory": InventoryManager.items,
		"character_states": _capture_character_states()
	}

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		print("Game saved successfully")
	else:
		print("Error: Could not save game")

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var text = file.get_as_text()
		file.close()

		var json = JSON.new()
		if json.parse(text) == OK:
			var data = json.data
			GameState.potions = data.get("potions", 0)
			GameState.party = data.get("party", ["Aria"])
			GameState.companions = data.get("companions", GameState.companions)
			InventoryManager.items = data.get("inventory", {})
			_restore_character_states(data.get("character_states", {}))
			print("Game loaded successfully")
		else:
			print("Error parsing save file")
	else:
		print("Error: Could not load save file")

func _capture_character_states() -> Dictionary:
	var states = {}
	for character_name in GameState.party:
		var char_data = _load_character_data(character_name)
		if char_data:
			states[character_name] = {
				"hp": char_data.hp,
				"mp": char_data.mp,
				"corruption_stage": char_data.corruption_stage,
				"captured": char_data.captured
			}
	return states

func _restore_character_states(states: Dictionary) -> void:
	for character_name in states:
		var char_data = _load_character_data(character_name)
		if char_data:
			var state = states[character_name]
			char_data.hp = state.get("hp", char_data.hp)
			char_data.mp = state.get("mp", char_data.mp)
			char_data.corruption_stage = state.get("corruption_stage", 0)
			char_data.captured = state.get("captured", false)

func _load_character_data(character_name: String) -> CharacterData:
	var char_path = "res://data/characters/" + character_name.to_lower() + ".tres"
	if ResourceLoader.exists(char_path):
		return load(char_path)
	return null

func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func delete_save() -> bool:
	if FileAccess.file_exists(SAVE_PATH):
		return DirAccess.remove_absolute(SAVE_PATH) == OK
	return true
