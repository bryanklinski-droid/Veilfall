class_name SkillData
extends Resource

@export var skill_name: String = ""
@export_multiline var description: String = ""
@export var skill_type: String = "Attack"  # Attack, Magic, Support, Passive
@export var mp_cost: int = 0
@export var power: int = 0  # Base damage/healing
@export var accuracy: float = 1.0  # 0.0-1.0
@export var hits: int = 1  # Number of hits
@export var target_type: String = "single_enemy"  # single_enemy, all_enemies, self, all_party
@export var effect: String = ""  # "heal", "poison", "stun", etc.
@export var learn_level: int = 1

func get_power_with_magic_stat(magic_stat: int) -> int:
	"""Calculate skill power including magic stat bonus"""
	@warning_ignore("integer_division")
	return power + (magic_stat / 10)

func get_total_cost() -> int:
	"""Get total cost for all hits"""
	return mp_cost * hits
