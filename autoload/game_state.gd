extends Node

var potions: int = 0
var party: Array[String] = ["Aria"]
var companions = {
	"Elara": {"recruited": false, "bond": 0, "captured": false, "corruption_stage": 0},
	"Lyra": {"recruited": false, "bond": 0, "captured": false, "corruption_stage": 0},
	"Selene": {"recruited": false, "bond": 0, "captured": false, "corruption_stage": 0},
	"Vivienne": {"recruited": false, "bond": 0, "captured": false, "corruption_stage": 0},
	"Freya": {"recruited": false, "bond": 0, "captured": false, "corruption_stage": 0}
}

var corruption_stage: int = 0
var corruption_days_remaining: int = 0
var escape_defeats: int = 0
var companionless_defeats: int = 0
var consecutive_companion_defeats: int = 0
var hero_captured: bool = false

func recruit_companion(name: String) -> void:
	if not companions.has(name):
		return
	companions[name]["recruited"] = true
	if not party.has(name):
		party.append(name)

func reset_new_game() -> void:
	potions = 0
	party = ["Aria"]
	corruption_stage = 0
	corruption_days_remaining = 0
	escape_defeats = 0
	companionless_defeats = 0
	consecutive_companion_defeats = 0
	hero_captured = false
	for name in companions:
		companions[name] = {
			"recruited": false,
			"bond": 0,
			"captured": false,
			"corruption_stage": 0
		}

func _ready() -> void:
	print(party)
