class_name DialogueUI
extends CanvasLayer

@export var dialogue_manager: DialogueManager
@export var text_speed: float = 0.05  # Seconds per character
@export var fade_duration: float = 0.3

var current_option_index: int = 0
var is_typing: bool = false
var is_visible: bool = false

func _ready() -> void:
	if not dialogue_manager:
		dialogue_manager = get_tree().root.find_child("DialogueManager", true, false)
	
	if dialogue_manager:
		dialogue_manager.dialogue_started.connect(_on_dialogue_started)
		dialogue_manager.dialogue_text_displayed.connect(_on_text_displayed)
		dialogue_manager.dialogue_options_shown.connect(_on_options_shown)
		dialogue_manager.dialogue_ended.connect(_on_dialogue_ended)
	
	hide_dialogue()

func _process(delta: float) -> void:
	if is_visible and Input.is_action_just_pressed("ui_accept"):
		if is_typing:
			_skip_text_animation()
		elif dialogue_manager.is_waiting_for_choice:
			_select_option()

## Show dialogue UI
func _on_dialogue_started(dialogue: DialogueData) -> void:
	show_dialogue()
	dialogue_manager.display_current_dialogue()

## Display text with typing effect
func _on_text_displayed(text: String) -> void:
	is_typing = true
	current_option_index = 0
	print(text)  # TODO: Animate text display in UI
	
	# Simulate typing animation
	var char_count = 0
	for char in text:
		await get_tree().create_timer(text_speed).timeout
		char_count += 1
	
	is_typing = false

## Show dialogue options for player selection
func _on_options_shown(options: Array[DialogueOption]) -> void:
	if options.is_empty():
		return
	
	current_option_index = 0
	print("\nOptions:")
	for i in range(options.size()):
		print("  [%d] %s" % [i + 1, options[i].text])
	
	dialogue_manager.is_waiting_for_choice = true

## Handle dialogue ending
func _on_dialogue_ended() -> void:
	await get_tree().create_timer(0.5).timeout
	hide_dialogue()

## Select current option
func _select_option() -> void:
	if dialogue_manager.current_dialogue:
		var available_options = dialogue_manager.current_dialogue.get_available_options()
		if current_option_index < available_options.size():
			dialogue_manager.advance_dialogue(current_option_index)

## Skip text animation
func _skip_text_animation() -> void:
	is_typing = false

## Show dialogue UI
func show_dialogue() -> void:
	is_visible = true
	# TODO: Animate in dialogue box
	print("=== DIALOGUE START ===")

## Hide dialogue UI
func hide_dialogue() -> void:
	is_visible = false
	# TODO: Animate out dialogue box
	print("=== DIALOGUE END ===")

## Get current available options
func get_current_options() -> Array[DialogueOption]:
	if dialogue_manager.current_dialogue:
		return dialogue_manager.current_dialogue.get_available_options()
	return []
