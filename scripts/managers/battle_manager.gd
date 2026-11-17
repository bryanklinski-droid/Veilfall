class_name BattleManager
extends Node

signal battle_started
signal turn_changed(current_unit: CombatUnit)
signal unit_acted(unit: CombatUnit, action: String)
signal unit_defeated(unit: CombatUnit)
signal battle_ended(victory: bool, rewards: Dictionary)
signal combat_message(message: String)

var party_units: Array[CombatUnit] = []
var enemy_units: Array[CombatUnit] = []
var all_units: Array[CombatUnit] = []
var current_turn_index := 0
var current_unit: CombatUnit = null
var battle_over := false
var total_experience := 0
var total_gold := 0
var dropped_items: Dictionary = {}

func init_battle(party_members: Array[CharacterData], enemies: Array[CharacterData]) -> void:
	party_units.clear()
	enemy_units.clear()
	all_units.clear()
	current_turn_index = 0
	current_unit = null
	battle_over = false
	total_experience = 0
	total_gold = 0
	dropped_items.clear()

	for member in party_members:
		var unit := CombatUnit.new()
		unit.character_data = member.duplicate(true)
		unit.is_player = true
		unit.current_hp = maxi(1, member.hp)
		unit.current_mp = maxi(0, member.mp)
		party_units.append(unit)
		all_units.append(unit)

	for enemy in enemies:
		var unit := CombatUnit.new()
		unit.character_data = enemy.duplicate(true)
		unit.current_hp = enemy.hp
		unit.current_mp = enemy.mp
		enemy_units.append(unit)
		all_units.append(unit)

	all_units.sort_custom(func(a: CombatUnit, b: CombatUnit) -> bool: return a.character_data.speed > b.character_data.speed)
	battle_started.emit()
	if party_units.is_empty() or enemy_units.is_empty():
		push_error("A battle needs a living party and at least one enemy.")
		battle_over = true
		return
	_advance_turn()

func _advance_turn() -> void:
	if battle_over:
		return
	for index in range(all_units.size()):
		if current_turn_index >= all_units.size():
			current_turn_index = 0
		current_unit = all_units[current_turn_index]
		current_turn_index += 1
		if current_unit.is_defeated():
			continue
		# Defend lasts through enemy attacks until this unit's next turn.
		current_unit.is_defending = false
		if current_unit.is_player and current_unit.grab_immunity_turns > 0:
			current_unit.grab_immunity_turns -= 1
		turn_changed.emit(current_unit)
		if not current_unit.is_player:
			_enemy_act()
		return
	_check_battle_end()

func execute_action(action: String, target: CombatUnit = null, skill: SkillData = null, item_id: String = "") -> bool:
	if current_unit == null or not current_unit.is_player or battle_over:
		return false
	if current_unit.is_restrained and action != "struggle":
		_announce("%s is restrained! Struggle to break free." % current_unit.character_data.display_name)
		return false

	var succeeded := false
	match action:
		"attack":
			if _is_valid_enemy_target(target):
				_perform_attack(current_unit, target)
				succeeded = true
		"defend":
			current_unit.is_defending = true
			_announce("%s braces for the next attack." % current_unit.character_data.display_name)
			succeeded = true
		"skill":
			succeeded = perform_skill(current_unit, skill, target)
		"item":
			succeeded = _use_item(current_unit, item_id, target)
		"struggle":
			current_unit.struggle_attempts += 1
			if current_unit.struggle_attempts >= 2 or randf() < 0.70:
				current_unit.is_restrained = false
				current_unit.struggle_attempts = 0
				current_unit.grab_immunity_turns = 1
				_announce("%s breaks free!" % current_unit.character_data.display_name)
			else:
				_announce("%s struggles, but the grip holds!" % current_unit.character_data.display_name)
			succeeded = true
		"rescue":
			if target != null and target.is_player and target.is_restrained and not target.is_defeated():
				target.is_restrained = false
				target.struggle_attempts = 0
				target.grab_immunity_turns = 1
				_announce("%s rescues %s!" % [current_unit.character_data.display_name, target.character_data.display_name])
				succeeded = true

	if not succeeded:
		_announce("That action is not available.")
		return false
	unit_acted.emit(current_unit, action)
	if not battle_over:
		_advance_turn()
	return true

func _enemy_act() -> void:
	if current_unit == null or battle_over:
		return
	var targets := get_valid_targets(current_unit)
	if targets.is_empty():
		_check_battle_end()
		return
	var target: CombatUnit = targets.pick_random()
	if current_unit.character_data is BossData:
		var boss := current_unit.character_data as BossData
		var abilities: Array[SkillData] = []
		if boss.should_use_phase_ability():
			abilities = boss.get_phase_abilities()
		if not abilities.is_empty():
			var skill: SkillData = abilities.pick_random()
			if perform_skill(current_unit, skill, target):
				unit_acted.emit(current_unit, "skill")
				if not battle_over:
					_advance_turn()
				return

	# First-pass restraint: readable, reversible, and available in normal encounters.
	# Future enemy families can define their own grab conditions and counters.
	if not target.is_restrained and target.grab_immunity_turns == 0 and randf() < 0.35:
		target.is_restrained = true
		target.struggle_attempts = 0
		_announce("%s grabs %s! Struggle or have an ally rescue them." % [current_unit.character_data.display_name, target.character_data.display_name])
		unit_acted.emit(current_unit, "grab")
	else:
		_perform_attack(current_unit, target)
		unit_acted.emit(current_unit, "attack")
	if not battle_over:
		_advance_turn()

func _is_valid_enemy_target(target: CombatUnit) -> bool:
	return target != null and enemy_units.has(target) and not target.is_defeated()

func _perform_attack(attacker: CombatUnit, defender: CombatUnit) -> void:
	if defender == null or defender.is_defeated():
		return
	var damage := maxi(1, attacker.character_data.get_attack() - defender.character_data.get_defense() + randi_range(-3, 3))
	var old_hp := defender.current_hp
	defender.take_damage(damage)
	var dealt := old_hp - defender.current_hp
	_announce("%s hits %s for %d damage." % [attacker.character_data.display_name, defender.character_data.display_name, dealt])
	if defender.is_defeated():
		_on_unit_killed(defender)
		_check_battle_end()

func perform_skill(attacker: CombatUnit, skill: SkillData, target: CombatUnit) -> bool:
	if attacker == null or skill == null or target == null or target.is_defeated():
		return false
	if attacker.current_mp < skill.mp_cost:
		_announce("Not enough MP for %s." % skill.skill_name)
		return false
	var heals := skill.effect.to_lower() == "heal" or skill.target_type in ["single_party", "self"]
	if heals and target.is_player != attacker.is_player:
		return false
	if not heals and target.is_player == attacker.is_player:
		return false
	if heals:
		if target.current_hp >= target.character_data.max_hp:
			_announce("%s is already at full HP." % target.character_data.display_name)
			return false
		attacker.current_mp -= skill.mp_cost
		var healed := maxi(1, skill.power + attacker.character_data.get_magic() / 5)
		target.restore_hp(healed)
		_announce("%s restores %s's HP." % [attacker.character_data.display_name, target.character_data.display_name])
	else:
		attacker.current_mp -= skill.mp_cost
		var damage := maxi(1, skill.power + attacker.character_data.get_magic() / 5 - target.character_data.get_magic() / 10)
		var old_hp := target.current_hp
		target.take_damage(damage)
		_announce("%s uses %s on %s for %d damage." % [attacker.character_data.display_name, skill.skill_name, target.character_data.display_name, old_hp - target.current_hp])
		if target.is_defeated():
			_on_unit_killed(target)
			_check_battle_end()
	return true

func _use_item(user: CombatUnit, item_id: String, target: CombatUnit) -> bool:
	if item_id.is_empty() or target == null or not target.is_player or target.is_defeated():
		return false
	if InventoryManager.get_item_count(item_id) <= 0:
		return false
	var item_path := "res://data/items/%s.tres" % item_id
	if not ResourceLoader.exists(item_path):
		return false
	var item := load(item_path) as ItemData
	if item == null or item.is_key_item or (item.hp_restore <= 0 and item.mp_restore <= 0):
		return false
	if (item.hp_restore <= 0 or target.current_hp >= target.character_data.max_hp) and (item.mp_restore <= 0 or target.current_mp >= target.character_data.max_mp):
		return false
	target.restore_hp(item.hp_restore)
	target.restore_mp(item.mp_restore)
	InventoryManager.remove_item(item_id, 1)
	_announce("%s uses %s on %s." % [user.character_data.display_name, item.item_name, target.character_data.display_name])
	return true

func _on_unit_killed(unit: CombatUnit) -> void:
	unit.is_restrained = false
	unit_defeated.emit(unit)
	if not unit.is_player:
		if unit.character_data is EnemyData:
			var enemy := unit.character_data as EnemyData
			total_experience += enemy.experience_reward
			total_gold += enemy.gold_reward
			for item_id in enemy.get_random_loot():
				dropped_items[item_id] = int(dropped_items.get(item_id, 0)) + 1
		else:
			total_experience += 25
			total_gold += 10

func _check_battle_end() -> bool:
	if battle_over:
		return true
	if enemy_units.all(func(u: CombatUnit) -> bool: return u.is_defeated()):
		battle_over = true
		battle_ended.emit(true, {"experience": total_experience, "gold": total_gold, "items": dropped_items.duplicate()})
		return true
	if party_units.all(func(u: CombatUnit) -> bool: return u.is_defeated()):
		battle_over = true
		for enemy in enemy_units:
			if not enemy.is_defeated():
				var event: DefeatEventData = DefeatEventManager.check_defeat_event(enemy.character_data, _get_party_names())
				if event != null:
					DefeatEventManager.start_defeat_event(event)
					DefeatEventManager.complete_defeat_event("unavoidable")
				break
		battle_ended.emit(false, {})
		return true
	return false

func get_valid_targets(unit: CombatUnit) -> Array[CombatUnit]:
	if unit.is_player:
		return enemy_units.filter(func(e: CombatUnit) -> bool: return not e.is_defeated())
	return party_units.filter(func(p: CombatUnit) -> bool: return not p.is_defeated())

func is_boss_battle() -> bool:
	return enemy_units.any(func(e: CombatUnit) -> bool: return e.character_data is BossData)

func get_bosses() -> Array[CombatUnit]:
	return enemy_units.filter(func(e: CombatUnit) -> bool: return e.character_data is BossData)

func _get_party_names() -> Array[String]:
	var names: Array[String] = []
	for unit in party_units:
		names.append(unit.character_data.display_name)
	return names

func _announce(message: String) -> void:
	combat_message.emit(message)
	print(message)
