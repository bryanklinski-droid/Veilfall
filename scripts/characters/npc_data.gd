class_name NPCData
extends Resource

@export var npc_id: String = ""
@export var display_name: String = ""
@export var npc_type: String = "generic"  # store_keeper, quest_giver, companion_event, corruption_event
@export_multiline var description: String = ""
@export var portrait_path: String = ""

# Dialogue interactions
@export var greeting_dialogue: DialogueData
@export var farewell_dialogue: DialogueData
@export var quest_dialogues: Array[DialogueData] = []  # Multiple quests this NPC offers
@export var event_dialogues: Array[DialogueData] = []  # Special event dialogues

# Store keeper specific
@export var shop_data: ShopData
@export var trade_enabled: bool = false

# Quest giver specific
@export var quests_offered: Array[String] = []  # Quest IDs this NPC offers
@export var quests_completed_count: int = 0

# Companion event specific
@export var companion_id: String = ""  # Which companion this event is for
@export var bond_requirement: int = 0  # Minimum bond level to trigger
@export var is_one_time_event: bool = false
@export var event_triggered: bool = false

# Corruption event specific
@export var corruption_threshold: int = 0  # Corruption level to trigger
@export var transforms_on_corruption: bool = false
@export var corrupted_form: NPCData

# State
var is_available: bool = true
var interaction_count: int = 0

func get_display_name() -> String:
	return display_name

func record_interaction() -> void:
	interaction_count += 1

func has_dialogue_available() -> bool:
	return greeting_dialogue != null or not quest_dialogues.is_empty() or not event_dialogues.is_empty()
