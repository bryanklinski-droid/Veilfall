class_name CharacterData
extends Resource

@export var display_name: String = ""
@export var level: int = 1
@export var max_hp: int = 100
@export var hp: int = 100
@export var max_mp: int = 30
@export var mp: int = 30
@export var attack: int = 10
@export var defense: int = 10
@export var magic: int = 10
@export var speed: int = 10
@export var corruption_stage: int = 0
@export var captured: bool = false
@export var weapon: ItemData
@export var armor: ItemData
@export var accessory_1: ItemData
@export var accessory_2: ItemData

func get_attack() -> int:
	var total := attack
	if weapon != null:
		total += weapon.attack_bonus
	return total

func get_defense() -> int:
	var total := defense
	if armor != null:
		total += armor.defense_bonus
	return total

func get_magic() -> int:
	var total := magic
	if accessory_1 != null:
		total += accessory_1.magic_bonus
	if accessory_2 != null:
		total += accessory_2.magic_bonus
	return total
