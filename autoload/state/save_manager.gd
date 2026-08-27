extends Node

const SAVE_PATH := "user://savegame.json"

func _ready() -> void:
	get_tree().scene_changed.connect(_on_scene_changed)
	load_game()

func _on_scene_changed() -> void:
	save_game()

func save_game() -> void:
	var data := {
		"party": GameState.party,
		"party_gold": GameState.party_gold,
		"party_experience": GameState.party_experience,
		"player_stats": GameState.player_stats,
		"companions": GameState.companions,
		"inventory": InventoryManager.items,
		"corruption_level": GameState.corruption_level,
		"corruption_stage": GameState.corruption_stage,
		"corruption_days_remaining": GameState.corruption_days_remaining,
		"hero_captured": GameState.hero_captured,
		"consecutive_companion_defeats": GameState.consecutive_companion_defeats,
		"companionless_defeats": GameState.companionless_defeats,
		"escape_defeats": GameState.escape_defeats,
		"world_progress": GameState.world_progress,
		"character_states": _capture_character_states()
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Could not open save file for writing: %s" % SAVE_PATH)
		return
	file.store_string(JSON.stringify(data))
	file.close()

func load_game() -> bool:
	if not has_save_file():
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("Could not open save file for reading: %s" % SAVE_PATH)
		return false
	var text := file.get_as_text()
	file.close()
	var json := JSON.new()
	if json.parse(text) != OK or not (json.data is Dictionary):
		push_error("Save file is invalid JSON")
		return false
	var data: Dictionary = json.data
	GameState.party.assign(data.get("party", ["Aria"]))
	GameState.party_gold = int(data.get("party_gold", 0))
	GameState.party_experience = int(data.get("party_experience", 0))
	GameState.player_stats = data.get("player_stats", GameState.player_stats)
	GameState.companions = data.get("companions", GameState.companions)
	InventoryManager.items = data.get("inventory", {})
	GameState.corruption_level = int(data.get("corruption_level", 0))
	GameState.corruption_stage = int(data.get("corruption_stage", 0))
	GameState.corruption_days_remaining = int(data.get("corruption_days_remaining", 7))
	GameState.hero_captured = bool(data.get("hero_captured", false))
	GameState.consecutive_companion_defeats = int(data.get("consecutive_companion_defeats", 0))
	GameState.companionless_defeats = int(data.get("companionless_defeats", 0))
	GameState.escape_defeats = int(data.get("escape_defeats", 0))
	GameState.world_progress = data.get("world_progress", GameState.world_progress)
	_restore_character_states(data.get("character_states", {}))
	return true

func _capture_character_states() -> Dictionary:
	var states := {}
	for character_name in GameState.party:
		var char_data := _load_character_data(character_name)
		if char_data != null:
			states[character_name] = {
				"hp": char_data.hp,
				"mp": char_data.mp,
				"corruption_stage": char_data.corruption_stage,
				"captured": char_data.captured
			}
	return states

func _restore_character_states(states: Dictionary) -> void:
	for character_name in states:
		var char_data := _load_character_data(character_name)
		if char_data != null:
			var state: Dictionary = states[character_name]
			char_data.hp = state.get("hp", char_data.hp)
			char_data.mp = state.get("mp", char_data.mp)
			char_data.corruption_stage = state.get("corruption_stage", 0)
			char_data.captured = state.get("captured", false)

func _load_character_data(character_name: String) -> CharacterData:
	var char_path := "res://data/characters/" + character_name.to_lower() + ".tres"
	if ResourceLoader.exists(char_path):
		return load(char_path)
	return null

func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func delete_save() -> bool:
	if FileAccess.file_exists(SAVE_PATH):
		return DirAccess.remove_absolute(SAVE_PATH) == OK
	return true
