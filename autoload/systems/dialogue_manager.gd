extends Node

signal dialogue_started(dialogue: DialogueData)
signal dialogue_text_displayed(text: String)
signal dialogue_options_shown(options: Array[DialogueOption])
signal dialogue_ended

var current_dialogue: DialogueData = null
var dialogue_queue: Array[DialogueData] = []
var is_showing_dialogue: bool = false
var is_waiting_for_choice: bool = false

## Start a dialogue
func start_dialogue(dialogue_id: String) -> bool:
	var dialogue = _load_dialogue(dialogue_id)
	if not dialogue:
		print("Error: Dialogue not found: ", dialogue_id)
		return false
	
	current_dialogue = dialogue
	is_showing_dialogue = true
	dialogue_started.emit(dialogue)
	return true

## Advance dialogue to next option
func advance_dialogue(option_index: int = 0) -> bool:
	if not current_dialogue or not is_showing_dialogue:
		return false
	
	var available_options = current_dialogue.get_available_options()
	
	if available_options.is_empty():
		# No options - end dialogue
		_end_dialogue()
		return true
	
	if option_index >= available_options.size():
		return false
	
	var selected_option = available_options[option_index]
	
	# Execute action if present
	if selected_option.action != "":
		_execute_action(selected_option.action, selected_option.action_param)
	
	# Advance to next dialogue
	if selected_option.next_dialogue_id == "":
		_end_dialogue()
	else:
		return start_dialogue(selected_option.next_dialogue_id)
	
	return true

## Display current dialogue
func display_current_dialogue() -> void:
	if not current_dialogue:
		return
	
	dialogue_text_displayed.emit(current_dialogue.text)
	
	var available_options = current_dialogue.get_available_options()
	if not available_options.is_empty():
		dialogue_options_shown.emit(available_options)
		is_waiting_for_choice = true

## End current dialogue
func _end_dialogue() -> void:
	is_showing_dialogue = false
	is_waiting_for_choice = false
	current_dialogue = null
	dialogue_ended.emit()

## Execute dialogue action
func _execute_action(action: String, param: String) -> void:
	match action:
		"quest_start":
			EventManager.start_quest(param)
			print("Quest started: ", param)
		
		"quest_advance":
			EventManager.advance_quest_stage(param)
			print("Quest advanced: ", param)
		
		"recruit":
			EventManager.recruit_companion_event(param, "dialogue")
			print("Recruited: ", param)
		
		"set_flag":
			EventManager.set_event_flag(param)
			print("Flag set: ", param)
		
		"give_item":
			InventoryManager.add_item(param, 1)
			print("Item given: ", param)
		
		"increase_bond":
			var parts = param.split(":")
			if parts.size() == 2:
				BondManager.increase_bond(parts[0], int(parts[1]))

## Load dialogue resource by ID
func _load_dialogue(dialogue_id: String) -> DialogueData:
	var dialogue_path = "res://data/dialogues/" + dialogue_id + ".tres"
	if ResourceLoader.exists(dialogue_path):
		return load(dialogue_path)
	
	print("Warning: Dialogue file not found: ", dialogue_path)
	return null

## Get all loaded dialogues (for debugging)
func get_loaded_dialogues() -> PackedStringArray:
	var dialogues = PackedStringArray()
	var dir = DirAccess.open("res://data/dialogues/")
	if dir:
		dir.list_dir_begin()
		var filename = dir.get_next()
		while filename != "":
			if filename.ends_with(".tres"):
				dialogues.append(filename.trim_suffix(".tres"))
			filename = dir.get_next()
	return dialogues
