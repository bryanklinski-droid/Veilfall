class_name CharacterData
extends Resource

@export var display_name: String = ""

@export var level: int = 1
@export var experience: int = 0
@export var skill_points: int = 0  # Points for skill tree progression

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

@export var starting_skills: Array[SkillData] = []

# Dynamic skill list (learned during gameplay)
var learned_skills: Array[SkillData] = []

func _init() -> void:
	learned_skills = starting_skills.duplicate()

func get_attack() -> int:
	var total = attack

	if weapon != null:
		total += weapon.attack_bonus

	return total

func get_defense() -> int:
	var total = defense

	if armor != null:
		total += armor.defense_bonus

	return total

func get_magic() -> int:
	var total = magic

	if accessory_1 != null:
		total += accessory_1.magic_bonus
	if accessory_2 != null:
		total += accessory_2.magic_bonus

	return total

## Get experience needed for next level
func get_exp_for_next_level() -> int:
	return 100 * level

## Check if character has learned a skill
func has_skill(skill: SkillData) -> bool:
	return learned_skills.has(skill)

## Learn a new skill
func learn_skill(skill: SkillData) -> bool:
	if not learned_skills.has(skill):
		learned_skills.append(skill)
		return true
	return false

## Get all available skills for current level
func get_available_skills() -> Array[SkillData]:
	var available = []
	for skill in learned_skills:
		if skill.learn_level <= level:
			available.append(skill)
	return available

## Calculate stat growth on level up
func level_up() -> Dictionary:
	var old_stats = {
		"hp": max_hp,
		"mp": max_mp,
		"attack": attack,
		"defense": defense,
		"magic": magic,
		"speed": speed
	}
	
	level += 1
	experience = 0
	skill_points += 1  # Grant skill point on level up
	
	# Level up stat growth (can be customized per character)
	max_hp += randi_range(8, 15)
	hp = max_hp
	max_mp += randi_range(3, 8)
	mp = max_mp
	attack += randi_range(2, 5)
	defense += randi_range(1, 3)
	magic += randi_range(2, 4)
	speed += randi_range(1, 2)
	
	# Check for new skills to learn
	var new_skills = []
	for skill in starting_skills:
		if skill.learn_level == level and not learned_skills.has(skill):
			learned_skills.append(skill)
			new_skills.append(skill)
	
	var growth = {
		"level": level,
		"old_stats": old_stats,
		"new_stats": {
			"hp": max_hp,
			"mp": max_mp,
			"attack": attack,
			"defense": defense,
			"magic": magic,
			"speed": speed
		},
		"new_skills": new_skills
	}
	
	return growth

## Add experience and handle level ups
func add_experience(amount: int) -> Array:
	experience += amount
	var level_ups = []
	
	while experience >= get_exp_for_next_level():
		level_ups.append(level_up())
	
	return level_ups
