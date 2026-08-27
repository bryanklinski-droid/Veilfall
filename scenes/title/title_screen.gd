extends Control

# UI Components
var title_label: Label
var subtitle_label: Label
var buttons_container: VBoxContainer
var new_game_button: Button
var continue_button: Button
var quit_button: Button

# Animation state
var title_tween: Tween
var buttons_tween: Tween

func _ready() -> void:
	_setup_ui()
	_load_save_state()
	_play_intro_animation()

func _setup_ui() -> void:
	# Background
	var background = TextureRect.new()
	background.texture = load("res://assets/ui/title_background.svg")
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.anchor_right = 1.0
	background.anchor_bottom = 1.0
	add_child(background)
	move_child(background, 0)
	
	# Initialize UI components
	title_label = Label.new()
	subtitle_label = Label.new()
	buttons_container = VBoxContainer.new()
	new_game_button = Button.new()
	continue_button = Button.new()
	quit_button = Button.new()
	
	# Title label
	title_label.text = "VEILFALL"
	title_label.anchor_left = 0.5
	title_label.anchor_top = 0.25
	title_label.anchor_right = 0.5
	title_label.anchor_bottom = 0.25
	title_label.offset_left = -150
	title_label.offset_top = -40
	title_label.offset_right = 150
	title_label.offset_bottom = 40
	title_label.add_theme_font_size_override("font_size", 80)
	title_label.add_theme_color_override("font_color", Color(0.67, 0.27, 1.0))  # Purple/Violet
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title_label)
	
	# Subtitle label
	subtitle_label.text = "Corruption of the Kingdom"
	subtitle_label.anchor_left = 0.5
	subtitle_label.anchor_top = 0.32
	subtitle_label.anchor_right = 0.5
	subtitle_label.anchor_bottom = 0.32
	subtitle_label.offset_left = -200
	subtitle_label.offset_top = -15
	subtitle_label.offset_right = 200
	subtitle_label.offset_bottom = 15
	subtitle_label.add_theme_font_size_override("font_size", 28)
	subtitle_label.add_theme_color_override("font_color", Color(0.5, 0.2, 0.8, 0.8))  # Darker purple
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(subtitle_label)
	
	# Buttons container
	buttons_container.anchor_left = 0.5
	buttons_container.anchor_top = 0.55
	buttons_container.anchor_right = 0.5
	buttons_container.anchor_bottom = 0.55
	buttons_container.offset_left = -150
	buttons_container.offset_top = 0
	buttons_container.offset_right = 150
	buttons_container.offset_bottom = 200
	buttons_container.add_theme_constant_override("separation", 15)
	buttons_container.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons_container.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	add_child(buttons_container)
	
	# New Game button
	new_game_button.text = "NEW GAME"
	new_game_button.custom_minimum_size = Vector2(300, 50)
	new_game_button.focus_mode = Control.FOCUS_ALL
	new_game_button.mouse_filter = Control.MOUSE_FILTER_STOP
	_style_button(new_game_button)
	new_game_button.pressed.connect(_on_new_game_button_pressed)
	buttons_container.add_child(new_game_button)
	
	# Continue button
	continue_button.text = "CONTINUE"
	continue_button.custom_minimum_size = Vector2(300, 50)
	continue_button.focus_mode = Control.FOCUS_ALL
	continue_button.mouse_filter = Control.MOUSE_FILTER_STOP
	continue_button.disabled = not SaveManager.has_save_file()
	_style_button(continue_button)
	continue_button.pressed.connect(_on_continue_button_pressed)
	buttons_container.add_child(continue_button)
	
	# Quit button
	quit_button.text = "QUIT"
	quit_button.custom_minimum_size = Vector2(300, 50)
	quit_button.focus_mode = Control.FOCUS_ALL
	quit_button.mouse_filter = Control.MOUSE_FILTER_STOP
	_style_button(quit_button)
	quit_button.pressed.connect(_on_quit_button_pressed)
	buttons_container.add_child(quit_button)
	
	# Set initial opacity for animation
	title_label.modulate.a = 0
	subtitle_label.modulate.a = 0
	buttons_container.modulate.a = 1  # Keep buttons visible for interaction

func _style_button(button: Button) -> void:
	button.add_theme_font_size_override("font_size", 24)
	button.add_theme_color_override("font_color", Color.CYAN)
	button.add_theme_color_override("font_hover_color", Color(0.2, 1.0, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.0, 0.8, 0.8))
	button.add_theme_color_override("font_disabled_color", Color(0.3, 0.3, 0.3))
	
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = Color(0.2, 0.1, 0.4, 0.6)
	stylebox.border_color = Color(0.67, 0.27, 1.0, 0.8)
	stylebox.set_border_width_all(2)
	button.add_theme_stylebox_override("normal", stylebox)
	
	var hover_box = stylebox.duplicate()
	hover_box.bg_color = Color(0.3, 0.15, 0.6, 0.8)
	button.add_theme_stylebox_override("hover", hover_box)
	
	var pressed_box = stylebox.duplicate()
	pressed_box.bg_color = Color(0.4, 0.2, 0.7, 0.9)
	button.add_theme_stylebox_override("pressed", pressed_box)

func _load_save_state() -> void:
	if SaveManager and SaveManager.has_save_file():
		continue_button.disabled = false
	else:
		continue_button.disabled = true

func _play_intro_animation() -> void:
	# Fade in title
	title_tween = create_tween()
	title_tween.tween_property(title_label, "modulate:a", 1.0, 1.0)
	title_tween.parallel()
	title_tween.tween_property(subtitle_label, "modulate:a", 1.0, 1.2)
	
	# Fade in buttons with delay
	buttons_tween = create_tween()
	buttons_tween.set_trans(Tween.TRANS_QUAD)
	buttons_tween.set_ease(Tween.EASE_OUT)
	buttons_tween.tween_interval(0.5)
	buttons_tween.tween_property(buttons_container, "modulate:a", 1.0, 0.8)
	
	# Subtle pulse effect on title
	await get_tree().create_timer(2.0).timeout
	var pulse_tween = create_tween()
	pulse_tween.set_loops()
	pulse_tween.tween_property(title_label, "modulate:a", 0.85, 1.5)
	pulse_tween.tween_property(title_label, "modulate:a", 1.0, 1.5)

func _on_new_game_button_pressed() -> void:
	print("New Game button pressed")
	# Delete old save and reset state for fresh start
	if SaveManager:
		SaveManager.delete_save()
	
	if GameState:
		GameState.party = ["Aria"]
		GameState.potions = 3
	
	if InventoryManager:
		InventoryManager.items.clear()
		# Add starting items
		InventoryManager.add_item("cell_key", 1)
	
	# Save and transition
	if SaveManager:
		SaveManager.save_game()
	_transition_to_world()

func _on_continue_button_pressed() -> void:
	print("Continue button pressed")
	# Load existing save
	if SaveManager and SaveManager.has_save_file():
		SaveManager.load_game()
		_transition_to_world()
	else:
		print("No save file found!")

func _on_quit_button_pressed() -> void:
	print("Quit button pressed")
	get_tree().quit()

func _transition_to_world() -> void:
	print("Transitioning to world...")
	# Fade out transition
	var fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await fade_tween.finished
	if ResourceLoader.exists("res://scenes/World/WorldMap.tscn"):
		get_tree().change_scene_to_file("res://scenes/World/WorldMap.tscn")
	else:
		print("ERROR: WorldMap.tscn not found!")
