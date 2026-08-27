extends Node2D

var battle_manager: BattleManager
var battle_ui: BattleUI

@export var default_enemies: Array[CharacterData] = []
@export var show_debug: bool = true

func _ready() -> void:
	battle_manager = BattleManager.new()
	add_child(battle_manager)
	battle_manager.name = "BattleManager"
	
	battle_ui = BattleUI.new()
	add_child(battle_ui)
	battle_ui.battle_manager = battle_manager
	battle_ui.name = "BattleUI"
	
	# Connect battle signals
	battle_manager.battle_started.connect(_on_battle_started)
	battle_manager.turn_changed.connect(_on_turn_changed)
	battle_manager.unit_acted.connect(_on_unit_acted)
	battle_manager.unit_defeated.connect(_on_unit_defeated)
	battle_manager.battle_ended.connect(_on_battle_ended)
	battle_ui.action_selected.connect(_on_action_selected)
	
	# Start battle with party vs enemies
	var party_members = []
	for member_name in GameState.party:
		var char_data = load("res://data/characters/" + member_name.to_lower() + ".tres")
		if char_data:
			# Apply bond modifiers before battle
			BondManager.apply_bond_modifiers(char_data)
			party_members.append(char_data)
	
	var enemies = default_enemies if not default_enemies.is_empty() else [load("res://data/characters/goblin.tres")]
	battle_manager.init_battle(party_members, enemies)
	
	# Detect boss battle
	var is_boss_battle = battle_manager.is_boss_battle()
	if is_boss_battle:
		print("=== BOSS BATTLE DETECTED ===")
		var bosses = battle_manager.get_bosses()
		for boss_unit in bosses:
			if boss_unit.character_data is BossData:
				var boss = boss_unit.character_data as BossData
				print("Boss: ", boss.display_name)
				print("Phases: ", boss.phase_thresholds.size())
	
	# Show intro effects
	EffectsManager.flash_screen(Color.WHITE, 0.3)
	
	if show_debug:
		print("Battle started!")

func _on_battle_started() -> void:
	if show_debug:
		print("Battle initialized!")
	battle_ui.update_battle_display()

func _on_turn_changed(unit: CombatUnit) -> void:
	if show_debug:
		print("\n--- %s's turn (Speed: %d) ---" % [unit.character_data.display_name, unit.character_data.speed])
	
	battle_ui.update_battle_display()
	
	if unit.is_player:
		# Wait for player input via UI
		pass
	# Enemy acts automatically

func _on_unit_acted(unit: CombatUnit, action: String) -> void:
	if show_debug:
		print("%s performed: %s" % [unit.character_data.display_name, action])

func _on_unit_defeated(unit: CombatUnit) -> void:
	if show_debug:
		print("%s was defeated!" % unit.character_data.display_name)
	battle_ui.show_message("%s was defeated!" % unit.character_data.display_name)

func _on_battle_ended(victory: bool, rewards: Dictionary) -> void:
	if show_debug:
		if victory:
			print("\n=== VICTORY ===")
			print("Experience gained: ", rewards.get("experience", 0))
			print("Gold gained: ", rewards.get("gold", 0))
		else:
			print("\n=== DEFEAT ===")
	
	# Visual effects
	if victory:
		AudioManager.play_sfx("res://assets/audio/victory.ogg")
		EffectsManager.flash_screen(Color.YELLOW, 0.5)
	else:
		AudioManager.play_sfx("res://assets/audio/defeat.ogg")
		EffectsManager.flash_screen(Color.RED, 0.5)
	
	# Apply rewards to party
	if victory:
		_apply_battle_rewards(rewards)
	
	# Show battle results screen
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/World/WorldMap.tscn")

## Apply experience and level ups
func _apply_battle_rewards(rewards: Dictionary) -> void:
	var exp_per_member = rewards.get("experience", 0) / battle_manager.party_units.size()
	var gold_gained = rewards.get("gold", 0)
	
	GameState.party_gold += gold_gained
	
	print("\nApplying rewards:")
	for unit in battle_manager.party_units:
		if unit.character_data:
			var level_ups = unit.character_data.add_experience(exp_per_member)
			
			print("%s gained %d XP" % [unit.character_data.display_name, exp_per_member])
			
			for level_up in level_ups:
				print("  %s leveled up to %d!" % [unit.character_data.display_name, level_up["level"]])
				if not level_up["new_skills"].is_empty():
					print("  New skills learned:")
					for skill in level_up["new_skills"]:
						print("    - %s" % skill.skill_name)
			
			# Increase bond after battle
			BondManager.increase_bond(unit.character_data.display_name, 5)
	
	print("Party gained %d gold!" % gold_gained)

## Handle player action selection from UI
func _on_action_selected(action: String, target: CombatUnit) -> void:
	if action == "attack":
		battle_manager.execute_action("attack", target)
	elif action == "defend":
		battle_manager.execute_action("defend")
	elif action == "skill":
		# TODO: Handle skill selection
		battle_manager.execute_action("attack", target)
	elif action == "item":
		battle_manager.execute_action("item")

func _on_attack_button_pressed() -> void:
	if battle_manager.current_unit and battle_manager.current_unit.is_player:
		var targets = battle_manager.get_valid_targets(battle_manager.current_unit)
		if not targets.is_empty():
			battle_manager.execute_action("attack", targets[0])

func _on_defend_button_pressed() -> void:
	if battle_manager.current_unit and battle_manager.current_unit.is_player:
		battle_manager.execute_action("defend")

func _on_item_button_pressed() -> void:
	if battle_manager.current_unit and battle_manager.current_unit.is_player:
		battle_manager.execute_action("item")

func _on_skill_button_pressed() -> void:
	if battle_manager.current_unit and battle_manager.current_unit.is_player:
		battle_manager.execute_action("skill")
