
extends Node

signal bond_increased(character: String, new_bond: int, max_bond: int)
signal bond_level_increased(character: String, new_level: int)
signal bond_event_triggered(character: String, event_type: String)

const MAX_BOND = 1000
const BOND_LEVEL_THRESHOLD = 200  # Points per level (0-4 = 5 levels)
const MAX_BOND_LEVEL = 5

var character_bonds: Dictionary = {}

func _ready() -> void:
	# Initialize bonds for all companions
	for character_name in GameState.companions:
		if not character_bonds.has(character_name):
			character_bonds[character_name] = {
				"points": 0,
				"level": 0,
				"events_triggered": []
			}

## Increase bond with a character
func increase_bond(character_name: String, amount: int = 10) -> void:
	if not GameState.companions.has(character_name):
		return
	
	if not character_bonds.has(character_name):
		character_bonds[character_name] = {
			"points": 0,
			"level": 0,
			"events_triggered": []
		}
	
	var bond_data = character_bonds[character_name]
	var old_level = bond_data["level"]
	
	bond_data["points"] = min(MAX_BOND, bond_data["points"] + amount)
	GameState.companions[character_name]["bond"] = bond_data["points"]
	
	# Check for level up
	var new_level = int(bond_data["points"] / BOND_LEVEL_THRESHOLD)
	new_level = min(MAX_BOND_LEVEL, new_level)
	
	if new_level > old_level:
		bond_data["level"] = new_level
		bond_level_increased.emit(character_name, new_level)
		_trigger_bond_event(character_name, new_level)
	
	bond_increased.emit(character_name, bond_data["points"], MAX_BOND)

## Decrease bond with a character
func decrease_bond(character_name: String, amount: int = 10) -> void:
	if not GameState.companions.has(character_name):
		return
	
	if not character_bonds.has(character_name):
		return
	
	var bond_data = character_bonds[character_name]
	bond_data["points"] = max(0, bond_data["points"] - amount)
	GameState.companions[character_name]["bond"] = bond_data["points"]
	
	bond_increased.emit(character_name, bond_data["points"], MAX_BOND)

## Get bond level (0-5)
func get_bond_level(character_name: String) -> int:
	if character_bonds.has(character_name):
		return character_bonds[character_name]["level"]
	return 0

## Get bond percentage for current level
func get_bond_percentage(character_name: String) -> float:
	if not character_bonds.has(character_name):
		return 0.0
	
	var bond_data = character_bonds[character_name]
	var current_level_threshold = bond_data["level"] * BOND_LEVEL_THRESHOLD
	var next_level_threshold = (bond_data["level"] + 1) * BOND_LEVEL_THRESHOLD
	var progress = bond_data["points"] - current_level_threshold
	var total = next_level_threshold - current_level_threshold
	
	return (float(progress) / float(total)) * 100.0 if total > 0 else 100.0

## Get stat bonus from bond level
func get_bond_stat_bonus(character_name: String, stat: String) -> int:
	var level = get_bond_level(character_name)
	if level == 0:
		return 0
	
	# Bonuses scale with bond level
	match stat:
		"attack":
			return level * 2
		"defense":
			return level * 2
		"magic":
			return level * 3
		"speed":
			return level * 1
		"max_hp":
			return level * 10
		_:
			return 0

## Trigger special bond event
func _trigger_bond_event(character_name: String, level: int) -> void:
	var event_type = "bond_level_%d" % level
	
	match level:
		1:
			print("%s: First bond level reached! Trust is building." % character_name)
			EventManager.set_event_flag("bond_" + character_name + "_level_1")
		2:
			print("%s: Growing closer... Bond is strengthening." % character_name)
			EventManager.set_event_flag("bond_" + character_name + "_level_2")
		3:
			print("%s: Deep connection formed. Special dialogue available." % character_name)
			EventManager.set_event_flag("bond_" + character_name + "_level_3")
		4:
			print("%s: Unshakeable bond. They'll fight harder for you." % character_name)
			EventManager.set_event_flag("bond_" + character_name + "_level_4")
		5:
			print("%s: Maximum bond reached! They're your trusted ally." % character_name)
			EventManager.set_event_flag("bond_" + character_name + "_level_5")
	
	bond_event_triggered.emit(character_name, event_type)

## Get all character bonds
func get_all_bonds() -> Dictionary:
	return character_bonds.duplicate(true)

## Apply bond stat modifiers to a character
func apply_bond_modifiers(character: CharacterData) -> void:
	var bonus = get_bond_stat_bonus(character.display_name, "attack")
	character.attack += bonus
	
	bonus = get_bond_stat_bonus(character.display_name, "defense")
	character.defense += bonus
	
	bonus = get_bond_stat_bonus(character.display_name, "magic")
	character.magic += bonus
	
	bonus = get_bond_stat_bonus(character.display_name, "speed")
	character.speed += bonus
	
	bonus = get_bond_stat_bonus(character.display_name, "max_hp")
	character.max_hp += bonus
