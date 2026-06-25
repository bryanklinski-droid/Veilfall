extends Node

var potions = 0
var party: Array[String] = ["Aria"]
var companions = {
	"Elara": {
		"recruited": false,
		"bond": 0,
		"captured": false,
		"corruption_stage": 0
	},
	"Lyra": {
		"recruited": false,
		"bond": 0,
		"captured": false,
		"corruption_stage": 0
	},
	"Selene": {
		"recruited": false,
		"bond": 0,
		"captured": false,
		"corruption_stage": 0
	},
	"Vivienne": {
		"recruited": false,
		"bond": 0,
		"captured": false,
		"corruption_stage": 0
	},
	"Freya": {
		"recruited": false,
		"bond": 0,
		"captured": false,
		"corruption_stage": 0
	}
}

func recruit_companion(name: String):
	if companions.has(name):
		companions[name]["recruited"] = true

	if not party.has(name):
		party.append(name)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.recruit_companion("Elara")
	GameState.recruit_companion("Lyra")
	GameState.recruit_companion("Selene")
	GameState.recruit_companion("Vivienne")
	GameState.recruit_companion("Freya")
	print(GameState.party)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
