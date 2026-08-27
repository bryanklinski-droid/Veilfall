class_name DialogueOption
extends Resource

@export var text: String = ""
@export var next_dialogue_id: String = ""  # ID of next dialogue, or empty for end
@export var condition_flag: String = ""    # Event flag that must be true to show
@export var action: String = ""            # Action to trigger (quest_start, recruit, etc)
@export var action_param: String = ""      # Parameter for action
