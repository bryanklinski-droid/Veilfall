class_name QuestData
extends Resource

@export var quest_id: String
@export var quest_name: String
@export var description: String = ""
@export var quest_type: String = "main"  # main, side, companion
@export var is_active: bool = false
@export var is_completed: bool = false
@export var stages: Array = []
@export var current_stage: int = 0
@export var rewards: Dictionary = {
	"experience": 0,
	"gold": 0,
	"items": {},
	"unlock_areas": []
}

var quest_log: Array[String] = []  # History of quest progression

func get_current_stage() -> QuestStage:
	if current_stage >= 0 and current_stage < stages.size():
		return stages[current_stage]
	return null

func advance_stage() -> bool:
	if current_stage < stages.size() - 1:
		current_stage += 1
		return true
	return false

func is_at_final_stage() -> bool:
	return current_stage == stages.size() - 1

func get_progress_percentage() -> float:
	if stages.size() == 0:
		return 0.0
	return (float(current_stage) / float(stages.size())) * 100.0

func add_log_entry(text: String) -> void:
	quest_log.append("[%s] %s" % [Time.get_ticks_msec(), text])

class QuestStage:
	var stage_number: int
	var objective: String
	var description: String = ""
	var is_complete: bool = false
	var progress: int = 0
	var progress_goal: int = 1
	var required_items: Array[String] = []  # Items needed to complete
	var required_defeats: Array[String] = []  # Enemies to defeat
	var required_area: String = ""  # Area to visit
	var completion_flag: String = ""  # Event flag to set on completion
	
	func _init(p_stage_number: int, p_objective: String, p_goal: int = 1) -> void:
		stage_number = p_stage_number
		objective = p_objective
		progress_goal = p_goal
	
	func check_completion() -> bool:
		return progress >= progress_goal
	
	func get_progress_string() -> String:
		return "%d/%d" % [progress, progress_goal]
