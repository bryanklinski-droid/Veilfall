extends Control

const WORLD_SCENE := "res://scenes/World/WorldMap.tscn"

var title_label: Label
var subtitle_label: Label
var menu_panel: PanelContainer
var buttons_container: VBoxContainer
var new_game_button: Button
var continue_button: Button
var quit_button: Button
var status_label: Label
var transition_overlay: ColorRect
var busy := false

func _ready() -> void:
	_setup_ui()
	_refresh_save_state()
	_play_intro_animation()
	new_game_button.grab_focus()

func _setup_ui() -> void:
	# Full-screen background.
	var background := TextureRect.new()
	background.texture = load("res://assets/ui/title_background.svg")
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	# Dark vignette so the menu remains readable at every resolution.
	var shade := ColorRect.new()
	shade.color = Color(0.018, 0.012, 0.035, 0.48)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	# Centered vertical composition.
	var root_box := VBoxContainer.new()
	root_box.anchor_left = 0.5
	root_box.anchor_top = 0.5
	root_box.anchor_right = 0.5
	root_box.anchor_bottom = 0.5
	root_box.offset_left = -310.0
	root_box.offset_top = -330.0
	root_box.offset_right = 310.0
	root_box.offset_bottom = 330.0
	root_box.alignment = BoxContainer.ALIGNMENT_CENTER
	root_box.add_theme_constant_override("separation", 10)
	add_child(root_box)

	var seal := TextureRect.new()
	seal.texture = load("res://assets/ui/seal_icon.svg")
	seal.custom_minimum_size = Vector2(112, 112)
	seal.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	seal.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	seal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root_box.add_child(seal)

	title_label = Label.new()
	title_label.text = "VEILFALL"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 66)
	title_label.add_theme_color_override("font_color", Color(0.88, 0.78, 1.0))
	title_label.add_theme_color_override("font_shadow_color", Color(0.2, 0.02, 0.32, 0.9))
	title_label.add_theme_constant_override("shadow_offset_x", 3)
	title_label.add_theme_constant_override("shadow_offset_y", 3)
	root_box.add_child(title_label)

	subtitle_label = Label.new()
	subtitle_label.text = "CORRUPTION OF THE KINGDOM"
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.add_theme_font_size_override("font_size", 20)
	subtitle_label.add_theme_color_override("font_color", Color(0.66, 0.56, 0.78))
	root_box.add_child(subtitle_label)

	var spacer := Control.new()
	spacer.custom_minimum_size.y = 24
	root_box.add_child(spacer)

	menu_panel = PanelContainer.new()
	menu_panel.custom_minimum_size = Vector2(410, 250)
	menu_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.035, 0.025, 0.065, 0.9)
	panel_style.border_color = Color(0.36, 0.18, 0.52, 0.9)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(8)
	panel_style.content_margin_left = 32
	panel_style.content_margin_right = 32
	panel_style.content_margin_top = 26
	panel_style.content_margin_bottom = 26
	menu_panel.add_theme_stylebox_override("panel", panel_style)
	root_box.add_child(menu_panel)

	buttons_container = VBoxContainer.new()
	buttons_container.add_theme_constant_override("separation", 14)
	menu_panel.add_child(buttons_container)

	new_game_button = _make_menu_button("NEW GAME")
	new_game_button.pressed.connect(_on_new_game_button_pressed)
	buttons_container.add_child(new_game_button)

	continue_button = _make_menu_button("CONTINUE")
	continue_button.pressed.connect(_on_continue_button_pressed)
	buttons_container.add_child(continue_button)

	quit_button = _make_menu_button("QUIT")
	quit_button.pressed.connect(_on_quit_button_pressed)
	buttons_container.add_child(quit_button)

	status_label = Label.new()
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 14)
	status_label.add_theme_color_override("font_color", Color(0.62, 0.56, 0.7))
	root_box.add_child(status_label)

	var controls_label := Label.new()
	controls_label.text = "Arrow Keys: Move    Z: Interact    X: Menu"
	controls_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls_label.add_theme_font_size_override("font_size", 13)
	controls_label.add_theme_color_override("font_color", Color(0.48, 0.44, 0.55))
	root_box.add_child(controls_label)

	# Fade overlay used while changing scenes.
	transition_overlay = ColorRect.new()
	transition_overlay.color = Color.BLACK
	transition_overlay.modulate.a = 0.0
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transition_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(transition_overlay)

func _make_menu_button(text_value: String) -> Button:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(340, 52)
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size", 21)
	button.add_theme_color_override("font_color", Color(0.88, 0.82, 0.96))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_focus_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color(0.78, 0.64, 0.92))
	button.add_theme_color_override("font_disabled_color", Color(0.34, 0.31, 0.38))

	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.09, 0.055, 0.14, 0.92)
	normal.border_color = Color(0.38, 0.2, 0.52, 0.9)
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(5)
	button.add_theme_stylebox_override("normal", normal)

	var hover := normal.duplicate()
	hover.bg_color = Color(0.18, 0.085, 0.27, 0.96)
	hover.border_color = Color(0.65, 0.38, 0.85, 1.0)
	hover.set_border_width_all(2)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("focus", hover)

	var pressed := normal.duplicate()
	pressed.bg_color = Color(0.26, 0.11, 0.35, 1.0)
	pressed.border_color = Color(0.78, 0.52, 0.94, 1.0)
	pressed.set_border_width_all(2)
	button.add_theme_stylebox_override("pressed", pressed)

	var disabled := normal.duplicate()
	disabled.bg_color = Color(0.04, 0.035, 0.055, 0.75)
	disabled.border_color = Color(0.18, 0.16, 0.22, 0.7)
	button.add_theme_stylebox_override("disabled", disabled)
	return button

func _refresh_save_state() -> void:
	var has_save := SaveManager.has_save_file()
	continue_button.disabled = not has_save
	if has_save:
		status_label.text = "A save file was found."
	else:
		status_label.text = "No save file found. Begin a new journey."

func _play_intro_animation() -> void:
	title_label.modulate.a = 0.0
	subtitle_label.modulate.a = 0.0
	menu_panel.modulate.a = 0.0
	status_label.modulate.a = 0.0

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(title_label, "modulate:a", 1.0, 0.45)
	tween.parallel().tween_property(subtitle_label, "modulate:a", 1.0, 0.65)
	tween.tween_property(menu_panel, "modulate:a", 1.0, 0.35)
	tween.parallel().tween_property(status_label, "modulate:a", 1.0, 0.35)

func _set_menu_enabled(enabled: bool) -> void:
	new_game_button.disabled = not enabled
	quit_button.disabled = not enabled
	continue_button.disabled = (not enabled) or (not SaveManager.has_save_file())

func _on_new_game_button_pressed() -> void:
	if busy:
		return
	busy = true
	_set_menu_enabled(false)
	status_label.text = "Beginning a new journey..."

	# Start from a genuinely clean state. Potions are inventory items found in the world,
	# so a new game does not create a legacy potion counter or hand out free potions.
	SaveManager.delete_save()
	GameState.reset_new_game()
	InventoryManager.items.clear()
	SaveManager.save_game()
	await _transition_to_world()

func _on_continue_button_pressed() -> void:
	if busy:
		return
	if not SaveManager.has_save_file():
		_refresh_save_state()
		return

	busy = true
	_set_menu_enabled(false)
	status_label.text = "Loading your journey..."
	if not SaveManager.load_game():
		busy = false
		_set_menu_enabled(true)
		status_label.text = "The save file could not be loaded."
		return
	await _transition_to_world()

func _on_quit_button_pressed() -> void:
	if not busy:
		get_tree().quit()

func _transition_to_world() -> void:
	if not ResourceLoader.exists(WORLD_SCENE):
		busy = false
		_set_menu_enabled(true)
		status_label.text = "World scene is missing: %s" % WORLD_SCENE
		push_error("WorldMap.tscn not found")
		return

	transition_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween := create_tween()
	tween.tween_property(transition_overlay, "modulate:a", 1.0, 0.35)
	await tween.finished
	get_tree().change_scene_to_file(WORLD_SCENE)
