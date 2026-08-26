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

func recruit_companion(name: String) -> void:
	if not companions.has(name):
		return
	companions[name]["recruited"] = true
	if not party.has(name):
		party.append(name)

func _ready() -> void:
	# Companions are recruited through gameplay, not automatically at startup.
	print(party)
