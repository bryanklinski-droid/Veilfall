class_name BattleManager
extends Node

signal battle_started
signal turn_changed(current_unit: CombatUnit)
signal unit_acted(unit: CombatUnit, action: String)
signal unit_defeated(unit: CombatUnit)
signal battle_ended(victory: bool, rewards: Dictionary)

var party_units: Array[CombatUnit] = []
var enemy_units: Array[CombatUnit] = []
var all_units: Array[CombatUnit] = []
var current_turn_index: int = 0
var current_unit: CombatUnit = null
var battle_over: bool = false
var total_experience: int = 0
var total_gold: int = 0

func _ready() -> void:
	pass

## Initialize battle with party members and enemies
func init_battle(party_members: Array[CharacterData], enemies: Array[CharacterData]) -> void:
	party_units.clear()
	enemy_units.clear()
	all_units.clear()
	current_turn_index = 0
	battle_over = false
	total_experience = 0
	total_gold = 0
	
	# Create combat units
	for member in party_members:
		var unit = CombatUnit.new()
		unit.character_data = member.duplicate()
		unit.is_player = true
		unit.current_hp = member.hp
		unit.current_mp = member.mp
		party_units.append(unit)
		all_units.append(unit)
	
	for enemy in enemies:
		var unit = CombatUnit.new()
		unit.character_data = enemy.duplicate()
		unit.is_player = false
		unit.current_hp = enemy.hp
		unit.current_mp = enemy.mp
		enemy_units.append(unit)
		all_units.append(unit)
	
	# Sort by speed for turn order
	all_units.sort_custom(func(a, b): return a.character_data.speed > b.character_data.speed)
	
	battle_started.emit()
	_advance_turn()

## Get next unit to act
func _advance_turn() -> void:
	if battle_over:
		return
	
	# Find next alive unit
	while current_turn_index < all_units.size():
		current_unit = all_units[current_turn_index]
		current_turn_index += 1
		
		if not current_unit.is_defeated():
			turn_changed.emit(current_unit)
			
			# AI acts for enemies
			if not current_unit.is_player:
				_enemy_act()
			return
		
		# Check for battle end after each death check
		if _check_battle_end():
			return
	
	# Reset turn order for next round
	current_turn_index = 0
	_advance_turn()

## Execute player action
func execute_action(action: String, target: CombatUnit = null) -> void:
	if not current_unit or current_unit.is_player == false or battle_over:
		return
	
	match action:
		"attack":
			_perform_attack(current_unit, target)
		"defend":
			_perform_defend(current_unit)
		"skill":
			# TODO: Handle skill usage
			pass
		"item":
			# TODO: Handle item usage
			pass
	
	unit_acted.emit(current_unit, action)
	
	if not battle_over:
		_advance_turn()

## Enemy AI logic
func _enemy_act() -> void:
	if not current_unit or current_unit.is_player or battle_over:
		return
	
	# Boss AI is more aggressive
	if current_unit.character_data is BossData:
		var boss = current_unit.character_data as BossData
		# Bosses have 50% chance to use special ability in certain phases
		if boss.should_use_phase_ability():
			# Use a phase ability if available
			var abilities = boss.get_phase_abilities()
			if abilities.size() > 0:
				var skill = abilities[randi() % abilities.size()]
				perform_skill(current_unit, skill, party_units[randi() % party_units.size()])
				unit_acted.emit(current_unit, "skill")
				if not battle_over:
					_advance_turn()
				return
	
	# Simple AI: attack random party member
	var target = party_units[randi() % party_units.size()]
	if not target.is_defeated():
		_perform_attack(current_unit, target)
	
	unit_acted.emit(current_unit, "attack")
	
	if not battle_over:
		_advance_turn()

## Check if enemy is a boss
func is_boss_battle() -> bool:
	for enemy in enemy_units:
		if enemy.character_data is BossData:
			return true
	return false

## Get all bosses in battle
func get_bosses() -> Array[CombatUnit]:
	var bosses = []
	for enemy in enemy_units:
		if enemy.character_data is BossData:
			bosses.append(enemy)
	return bosses

## Perform attack action
func _perform_attack(attacker: CombatUnit, defender: CombatUnit) -> void:
	if not defender or defender.is_defeated():
		return
	
	var damage = max(1, attacker.character_data.get_attack() - defender.character_data.get_defense() + randi_range(-5, 5))
	
	# Reduce damage if defending
	if defender.is_defending:
		damage = max(1, damage / 2)
	
	defender.current_hp -= damage
	
	# Play effects
	AudioManager.play_battle_sound("attack")
	EffectsManager.show_damage_text(Vector2(640, 360), damage, false)
	EffectsManager.spawn_particle_effect("slash", Vector2(640, 360))
	
	print("%s attacks %s for %d damage!" % [attacker.character_data.display_name, defender.character_data.display_name, damage])
	
	if defender.is_defeated():
		unit_defeated.emit(defender)
		if not defender.is_player:
			# Reward for defeating enemy
			if defender.character_data is EnemyData:
				total_experience += defender.character_data.experience_reward
				total_gold += defender.character_data.gold_reward
		_check_battle_end()


## Perform skill action
func perform_skill(attacker: CombatUnit, skill: SkillData, target: CombatUnit) -> void:
	if not attacker or attacker.current_mp < skill.mp_cost or skill == null:
		return
	
	# Consume MP
	attacker.current_mp -= skill.mp_cost
	
	match skill.skill_type:
		"Attack":
			var damage = max(1, skill.power + attacker.character_data.get_magic() / 5 - target.character_data.get_magic() / 10)
			target.current_hp -= damage
			print("%s uses %s on %s for %d damage!" % [attacker.character_data.display_name, skill.skill_name, target.character_data.display_name, damage])
			
			if target.is_defeated():
				unit_defeated.emit(target)
				_check_battle_end()
		
		"Magic":
			var healing = skill.power + attacker.character_data.get_magic() / 5
			target.restore_hp(int(healing))
			print("%s uses %s to heal %s for %d HP!" % [attacker.character_data.display_name, skill.skill_name, target.character_data.display_name, int(healing)])
		
		"Support":
			print("%s uses support skill %s!" % [attacker.character_data.display_name, skill.skill_name])
	
	unit_acted.emit(attacker, "skill_" + skill.skill_name)

## Perform defend action
func _perform_defend(unit: CombatUnit) -> void:
	unit.is_defending = true
	print("%s defends!" % unit.character_data.display_name)

## Check if battle has ended
func _check_battle_end() -> bool:
	# Check if all enemies defeated
	var all_enemies_defeated = true
	for enemy in enemy_units:
		if not enemy.is_defeated():
			all_enemies_defeated = false
			break
	
	if all_enemies_defeated:
		battle_over = true
		var rewards = {"experience": total_experience, "gold": total_gold}
		battle_ended.emit(true, rewards)
		return true
	
	# Check if all party defeated
	var all_party_defeated = true
	for member in party_units:
		if not member.is_defeated():
			all_party_defeated = false
			break
	
	if all_party_defeated:
		battle_over = true
		
		# Check for defeat event from boss or enemy
		var defeating_enemy = null
		for enemy in enemy_units:
			if not enemy.is_defeated():
				defeating_enemy = enemy
				break
		
		if defeating_enemy and DefeatEventManager:
			var defeat_event = DefeatEventManager.check_defeat_event(defeating_enemy.character_data, _get_party_names())
			if defeat_event:
				# Trigger defeat event instead of normal defeat
				if DialogueManager and defeat_event.initial_dialogue:
					DialogueManager.start_dialogue(defeat_event.initial_dialogue)
				# Apply consequences
				DefeatEventManager.apply_defeat_consequences(defeat_event)
		
		battle_ended.emit(false, {})
		return true
	
	return false

## Get list of valid targets (living enemies for party, living party for enemies)
func get_valid_targets(unit: CombatUnit) -> Array[CombatUnit]:
	if unit.is_player:
		return enemy_units.filter(func(e): return not e.is_defeated())
	else:
		return party_units.filter(func(p): return not p.is_defeated())

## Helper: Get party member names for defeat event
func _get_party_names() -> Array[String]:
	var names: Array[String] = []
	for unit in party_units:
		names.append(unit.character_data.display_name)
	return names
