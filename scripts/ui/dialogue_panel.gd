class_name DialoguePanel
extends PanelContainer

signal option_selected(option_index: int)
signal dialogue_closed

var speaker_label: Label
var dialogue_text: RichTextLabel
var options_container: VBoxContainer

var current_dialogue: DialogueData = null
var is_animating: bool = false
var animation_speed: float = 0.02  # seconds per character

func _ready() -> void:
	# Initialize UI nodes
	speaker_label = Label.new()
	dialogue_text = RichTextLabel.new()
	options_container = VBoxContainer.new()
	
	# Setup UI structure
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	add_child(margin)
	
	var vbox = VBoxContainer.new()
	margin.add_child(vbox)
	
	# Speaker name with styling
	speaker_label.add_theme_font_size_override("font_size", 24)
	speaker_label.text = "Speaker"
	speaker_label.add_theme_color_override("font_color", Color.GOLD)
	vbox.add_child(speaker_label)
	
	# Dialogue text
	dialogue_text.custom_minimum_size = Vector2(600, 100)
	dialogue_text.bbcode_enabled = true
	vbox.add_child(dialogue_text)
	
	# Options container
	options_container.separation = 10
	vbox.add_child(options_container)
	
	# Connect dialogue manager signals
	if DialogueManager:
		DialogueManager.dialogue_started.connect(_on_dialogue_started)
		DialogueManager.dialogue_text_displayed.connect(_on_text_displayed)
		DialogueManager.dialogue_options_shown.connect(_on_options_shown)
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	
	# Initial state
	modulate.a = 0.0
	hide()

func _on_dialogue_started(dialogue_id: String) -> void:
	current_dialogue = DialogueManager._load_dialogue(dialogue_id)
	if not current_dialogue:
		return
	
	show()
	
	# Smooth fade-in
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	
	speaker_label.text = current_dialogue.speaker_name
	dialogue_text.clear()
	
	# Animate text
	_animate_text(current_dialogue.text)

func _animate_text(text: String) -> void:
	is_animating = true
	dialogue_text.clear()
	
	for i in range(text.length()):
		dialogue_text.append_text(text[i])
		await get_tree().create_timer(animation_speed).timeout
	
	is_animating = false

func _on_text_displayed(dialogue_id: String) -> void:
	# Text already displayed through animation
	pass

func _on_options_shown(options: Array[DialogueOption]) -> void:
	# Clear previous options
	for child in options_container.get_children():
		child.queue_free()
	
	# Create option buttons with animation
	for i in range(options.size()):
		var option = options[i]
		var button = Button.new()
		button.text = option.text
		button.modulate.a = 0.0
		button.pressed.connect(func(): _on_option_selected(i))
		options_container.add_child(button)
		
		# Staggered fade-in for options
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(button, "modulate:a", 1.0, 0.2)

func _on_option_selected(option_index: int) -> void:
	option_selected.emit(option_index)
	DialogueManager.advance_dialogue(option_index)

func _on_dialogue_ended(dialogue_id: String) -> void:
	# Smooth fade-out
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	
	await tween.finished
	hide()
	dialogue_closed.emit()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			if is_animating:
				# Skip animation
				dialogue_text.clear()
				if current_dialogue:
					dialogue_text.append_text(current_dialogue.text)
				is_animating = false
				get_tree().root.set_input_as_handled()
