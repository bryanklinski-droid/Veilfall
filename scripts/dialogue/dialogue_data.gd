class_name DialogueData
extends Resource

@export var dialogue_id: String = ""
@export var speaker_name: String = ""
@export_multiline var text: String = ""
@export var portrait_path: String = ""  # Path to character portrait/sprite
@export var options: Array[DialogueOption] = []
@export var auto_advance_delay: float = 0.0  # 0 = wait for input, >0 = auto advance after delay

## Check if this dialogue has player choices
func has_choices() -> bool:
	return not options.is_empty()

## Get available options (filters by condition flags)
func get_available_options() -> Array[DialogueOption]:
	var available = []
	for option in options:
		if option.condition_flag == "" or EventManager.is_event_flagged(option.condition_flag):
			available.append(option)
	return available
