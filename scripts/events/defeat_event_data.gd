class_name DefeatEventData
extends Resource

@export var event_id: String = ""
@export var event_type: String = ""  # boss_defeat, humanoid_defeat, monster_defeat, beast_defeat
@export var trigger_character: String = ""  # Which character/enemy triggers this
@export var is_story_event: bool = false  # Important story moment
@export var corrupts_player: bool = false  # Increases player corruption
@export var corruption_increase: int = 0  # How much corruption

# Dialogue sequence for the event
@export var initial_dialogue: DialogueData
@export var encounter_dialogues: Array[DialogueData] = []  # During event
@export var outcome_dialogue: DialogueData  # After event

# Gameplay consequences
@export var stat_penalties: Dictionary = {}  # "hp": 10, "max_hp": 20, etc
@export var item_loss: Array[String] = []  # Items lost after defeat
@export var items_dropped: Array[String] = []  # Items enemy leaves

# Consequences for party
@export var affected_companions: Array[String] = []  # Which companions are affected
@export var bond_changes: Dictionary = {}  # companion -> bond_change (negative)
@export var trauma_effects: Dictionary = {}  # companion -> trauma_level

# Recovery requirements
@export var recovery_location: String = ""  # Where player wakes up
@export var recovery_items_required: Array[String] = []  # Must use items to recover
@export var rest_time_required: int = 0  # In-game time units needed

var triggered: bool = false
var last_triggered_timestamp: int = 0

func mark_triggered() -> void:
	triggered = true
	last_triggered_timestamp = Time.get_ticks_msec()

func can_trigger_again() -> bool:
	if not triggered:
		return true
	# Can trigger again after 60 seconds (for testing)
	var time_elapsed = Time.get_ticks_msec() - last_triggered_timestamp
	return time_elapsed > 60000
