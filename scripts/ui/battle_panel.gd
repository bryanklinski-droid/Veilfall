class_name BattlePanel
extends Control

signal action_selected(action: String, target_index: int)

var party_status: VBoxContainer
var enemy_status: VBoxContainer
var action_menu: HBoxContainer
var message_label: Label
var turn_label: Label

var current_unit: CombatUnit = null
var party_units: Array[CombatUnit] = []
var enemy_units: Array[CombatUnit] = []
var selected_action: String = ""

func _ready() -> void:
	party_status = VBoxContainer.new()
	enemy_status = VBoxContainer.new()
	action_menu = HBoxContainer.new()
	message_label = Label.new()
	turn_label = Label.new()
	setup_ui()
	modulate.a = 0.0  # Start hidden
	
	if BattleManager:
		BattleManager.turn_changed.connect(_on_turn_changed)
		BattleManager.unit_acted.connect(_on_unit_acted)
		BattleManager.unit_defeated.connect(_on_unit_defeated)
		
		# Smooth fade-in when battle starts
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "modulate:a", 1.0, 0.5)

func setup_ui() -> void:
	var main_hbox = HBoxContainer.new()
	main_hbox.anchor_right = 1.0
	main_hbox.anchor_bottom = 1.0
	add_child(main_hbox)
	
	# Party status on left
	var party_panel = PanelContainer.new()
	party_status.custom_minimum_size = Vector2(300, 400)
	party_panel.add_child(party_status)
	main_hbox.add_child(party_panel)
	
	# Combat log in center
	var center_vbox = VBoxContainer.new()
	center_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	turn_label.text = "Turn: ?"
	turn_label.add_theme_font_size_override("font_size", 20)
	turn_label.add_theme_color_override("font_color", Color.YELLOW)
	center_vbox.add_child(turn_label)
	
	message_label.custom_minimum_size = Vector2(0, 200)
	message_label.text = "Battle started!"
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	center_vbox.add_child(message_label)
	
	# Action menu
	action_menu.custom_minimum_size = Vector2(0, 100)
	center_vbox.add_child(action_menu)
	
	main_hbox.add_child(center_vbox)
	
	# Enemy status on right
	var enemy_panel = PanelContainer.new()
	enemy_status.custom_minimum_size = Vector2(300, 400)
	enemy_panel.add_child(enemy_status)
	main_hbox.add_child(enemy_panel)

func update_display() -> void:
	# Clear and rebuild status displays
	for child in party_status.get_children():
		child.queue_free()
	for child in enemy_status.get_children():
		child.queue_free()
	
	if BattleManager:
		for unit in BattleManager.party_units:
			_create_unit_display(unit, party_status)
		
		for unit in BattleManager.enemy_units:
			_create_unit_display(unit, enemy_status)

func _create_unit_display(unit: CombatUnit, container: VBoxContainer) -> void:
	var hbox = HBoxContainer.new()
	
	# Name and level with styling
	var name_label = Label.new()
	name_label.text = "%s (Lv%d)" % [unit.character_data.display_name, unit.character_data.level]
	name_label.add_theme_color_override("font_color", Color.CYAN)
	hbox.add_child(name_label)
	
	# Status
	var status_label = Label.new()
	var hp_percent = int((float(unit.current_hp) / unit.character_data.max_hp) * 100)
	var mp_percent = int((float(unit.current_mp) / unit.character_data.max_mp) * 100)
	status_label.text = "HP: %d%% | MP: %d%%" % [hp_percent, mp_percent]
	status_label.add_theme_color_override("font_color", _get_status_color(hp_percent))
	hbox.add_child(status_label)
	
	container.add_child(hbox)
	
	# HP Bar with animation
	var hp_bar = ProgressBar.new()
	hp_bar.max_value = unit.character_data.max_hp
	hp_bar.value = unit.current_hp
	hp_bar.custom_minimum_size = Vector2(200, 20)
	hp_bar.self_modulate = Color.WHITE
	container.add_child(hp_bar)
	
	# Pulse animation on creation
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	tween.tween_property(hp_bar, "scale", Vector2.ONE * 1.05, 0.2)
	tween.tween_callback(func():
		var tween2 = create_tween()
		tween2.set_trans(Tween.TRANS_CUBIC)
		tween2.tween_property(hp_bar, "scale", Vector2.ONE, 0.2)
	)

func _get_status_color(percent: int) -> Color:
	if percent > 50:
		return Color.GREEN
	elif percent > 25:
		return Color.YELLOW
	return Color.RED

func _on_turn_changed(unit: CombatUnit) -> void:
	current_unit = unit
	turn_label.text = "Turn: %s" % unit.character_data.display_name
	
	update_display()
	
	if unit.is_player:
		_show_action_menu()
	else:
		# Enemy turn - disable menu
		_clear_action_menu()

func _show_action_menu() -> void:
	_clear_action_menu()
	
	var attack_btn = Button.new()
	attack_btn.text = "Attack"
	attack_btn.pressed.connect(func(): _select_action("attack"))
	action_menu.add_child(attack_btn)
	
	var defend_btn = Button.new()
	defend_btn.text = "Defend"
	defend_btn.pressed.connect(func(): _select_action("defend"))
	action_menu.add_child(defend_btn)
	
	var skill_btn = Button.new()
	skill_btn.text = "Skills"
	skill_btn.pressed.connect(func(): _show_skills())
	action_menu.add_child(skill_btn)
	
	var item_btn = Button.new()
	item_btn.text = "Items"
	item_btn.pressed.connect(func(): _show_items())
	action_menu.add_child(item_btn)

func _select_action(action: String) -> void:
	selected_action = action
	message_label.text = "Select target for: %s" % action
	_show_target_menu()

func _show_target_menu() -> void:
	_clear_action_menu()
	
	var targets = BattleManager.enemy_units if selected_action in ["attack", "skill"] else BattleManager.party_units
	
	for i in range(targets.size()):
		var target = targets[i]
		var btn = Button.new()
		btn.text = target.character_data.display_name
		btn.pressed.connect(func(): action_selected.emit(selected_action, i))
		action_menu.add_child(btn)

func _show_skills() -> void:
	_clear_action_menu()
	
	var skills = current_unit.character_data.get_available_skills()
	for skill in skills:
		var btn = Button.new()
		btn.text = "%s (MP: %d)" % [skill.skill_name, skill.mp_cost]
		btn.pressed.connect(func(): action_selected.emit("skill:%s" % skill.skill_name, 0))
		action_menu.add_child(btn)

func _show_items() -> void:
	_clear_action_menu()
	
	var items = ["small_potion"]  # Placeholder
	for item_id in items:
		if InventoryManager.has_item(item_id):
			var btn = Button.new()
			btn.text = item_id
			btn.pressed.connect(func(): action_selected.emit("item:%s" % item_id, 0))
			action_menu.add_child(btn)

func _clear_action_menu() -> void:
	for child in action_menu.get_children():
		child.queue_free()

func _on_unit_acted(unit: CombatUnit, action: String) -> void:
	message_label.text = "%s used %s!" % [unit.character_data.display_name, action]

func _on_unit_defeated(unit: CombatUnit) -> void:
	message_label.text = "%s was defeated!" % unit.character_data.display_name
	update_display()

func show_message(text: String) -> void:
	message_label.text = text
