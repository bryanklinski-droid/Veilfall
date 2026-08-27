class_name CombatUnit

var character_data: CharacterData
var is_player: bool = false
var current_hp: int = 0
var current_mp: int = 0
var is_defending: bool = false

func is_defeated() -> bool:
	return current_hp <= 0

func take_damage(amount: int) -> void:
	if is_defending:
		amount = max(1, amount / 2)  # Reduce damage when defending
	current_hp = max(0, current_hp - amount)

func restore_hp(amount: int) -> void:
	current_hp = min(character_data.max_hp, current_hp + amount)

func restore_mp(amount: int) -> void:
	current_mp = min(character_data.max_mp, current_mp + amount)

func get_hp_percentage() -> float:
	if character_data.max_hp <= 0:
		return 0.0
	return float(current_hp) / float(character_data.max_hp)

func get_mp_percentage() -> float:
	if character_data.max_mp <= 0:
		return 0.0
	return float(current_mp) / float(character_data.max_mp)
