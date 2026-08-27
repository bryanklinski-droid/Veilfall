
extends CanvasLayer

## Screen effects and visual polish

var camera_ref: Camera2D = null

func _ready() -> void:
	print("EffectsManager ready - visual effects available")

## Fade screen to black and back
func fade_to_black(duration: float = 1.0, hold_duration: float = 0.0) -> void:
	var black_rect = ColorRect.new()
	black_rect.color = Color.BLACK
	black_rect.modulate.a = 0.0
	add_child(black_rect)
	black_rect.anchor_left = 0.0
	black_rect.anchor_top = 0.0
	black_rect.anchor_right = 1.0
	black_rect.anchor_bottom = 1.0
	
	var tween = create_tween()
	tween.tween_property(black_rect, "modulate:a", 1.0, duration)
	
	if hold_duration > 0:
		tween.tween_callback(func(): await get_tree().create_timer(hold_duration).timeout)
	
	tween.tween_property(black_rect, "modulate:a", 0.0, duration)
	await tween.finished
	black_rect.queue_free()

## Screen shake effect
func screen_shake(_intensity: float = 5.0, _duration: float = 0.5) -> void:
	# TODO: Implement proper camera shake later.
	return
	
	

## Flash screen with color
func flash_screen(color: Color, duration: float = 0.3) -> void:
	var flash_rect = ColorRect.new()
	flash_rect.color = color
	flash_rect.modulate.a = 0.0
	add_child(flash_rect)
	flash_rect.anchor_left = 0.0
	flash_rect.anchor_top = 0.0
	flash_rect.anchor_right = 1.0
	flash_rect.anchor_bottom = 1.0
	
	var tween = create_tween()
	tween.tween_property(flash_rect, "modulate:a", 1.0, duration * 0.5)
	tween.tween_property(flash_rect, "modulate:a", 0.0, duration * 0.5)
	await tween.finished
	flash_rect.queue_free()

## Floating damage text
func show_damage_text(position: Vector2, damage: int, is_heal: bool = false) -> void:
	var label = Label.new()
	label.text = str(damage)
	label.add_theme_font_size_override("font_size", 24)
	
	if is_heal:
		label.add_theme_color_override("font_color", Color.GREEN)
	else:
		label.add_theme_color_override("font_color", Color.RED)
	
	add_child(label)
	label.global_position = position
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "global_position:y", position.y - 50, 1.0)
	tween.tween_property(label, "modulate:a", 0.0, 1.0)
	
	await tween.finished
	label.queue_free()

## Particle effect at position
func spawn_particle_effect(effect_type: String, position: Vector2) -> void:
	match effect_type:
		"slash":
			_spawn_slash_effect(position)
		"heal":
			_spawn_heal_effect(position)
		"spell":
			_spawn_spell_effect(position)
		"impact":
			_spawn_impact_effect(position)

func _spawn_slash_effect(position: Vector2) -> void:
	# Create animated slash lines
	var slash_line = Line2D.new()
	slash_line.modulate.a = 0.8
	add_child(slash_line)
	slash_line.global_position = position
	
	# Draw a diagonal slash
	slash_line.add_point(Vector2(-30, -30))
	slash_line.add_point(Vector2(30, 30))
	slash_line.width = 4.0
	slash_line.default_color = Color.WHITE
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(slash_line, "modulate:a", 0.0, 0.3)
	tween.tween_property(slash_line, "scale", Vector2.ONE * 1.5, 0.3)
	
	await tween.finished
	slash_line.queue_free()

func _spawn_heal_effect(position: Vector2) -> void:
	# Create green sparkles for healing
	var heal_container = Node2D.new()
	add_child(heal_container)
	heal_container.global_position = position
	
	for i in range(8):
		var sparkle = Label.new()
		sparkle.text = "✨"
		sparkle.add_theme_font_size_override("font_size", 16)
		heal_container.add_child(sparkle)
		
		var angle = (i / 8.0) * TAU
		var start_pos = Vector2(cos(angle), sin(angle)) * 10
		sparkle.position = start_pos
		
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_QUAD)
		tween.set_ease(Tween.EASE_OUT)
		tween.set_parallel(true)
		
		tween.tween_property(sparkle, "position", start_pos + Vector2(cos(angle), sin(angle)) * 40, 0.6)
		tween.tween_property(sparkle, "modulate:a", 0.0, 0.6)
	
	await get_tree().create_timer(0.7).timeout
	heal_container.queue_free()

func _spawn_spell_effect(position: Vector2) -> void:
	# Create magical aura effect
	var aura = Panel.new()
	aura.modulate = Color.CYAN
	aura.modulate.a = 0.4
	add_child(aura)
	aura.global_position = position
	aura.custom_minimum_size = Vector2(40, 40)
	aura.position -= aura.custom_minimum_size / 2
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	
	tween.tween_property(aura, "custom_minimum_size", Vector2(100, 100), 0.4)
	tween.tween_property(aura, "position", aura.position - Vector2(30, 30), 0.4)
	tween.tween_property(aura, "modulate:a", 0.0, 0.4)
	
	await tween.finished
	aura.queue_free()

func _spawn_impact_effect(position: Vector2) -> void:
	# Create impact radiating circles
	var impact_circle = Panel.new()
	impact_circle.modulate = Color.WHITE
	impact_circle.modulate.a = 0.6
	add_child(impact_circle)
	impact_circle.global_position = position
	impact_circle.custom_minimum_size = Vector2(20, 20)
	impact_circle.position -= impact_circle.custom_minimum_size / 2
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	
	tween.tween_property(impact_circle, "custom_minimum_size", Vector2(80, 80), 0.5)
	tween.tween_property(impact_circle, "position", impact_circle.position - Vector2(30, 30), 0.5)
	tween.tween_property(impact_circle, "modulate:a", 0.0, 0.5)
	
	await tween.finished
	impact_circle.queue_free()

## Camera focus on position
func camera_focus(_position: Vector2, _duration: float = 0.5) -> void:
	# TODO: Implement camera system
	pass

## Character slide animation
func slide_character(node: Node, from_pos: Vector2, to_pos: Vector2, duration: float = 0.3) -> void:
	node.global_position = from_pos
	var tween = create_tween()
	tween.tween_property(node, "global_position", to_pos, duration)
	await tween.finished

## Pop in animation
func pop_in(node: Node, duration: float = 0.3) -> void:
	node.scale = Vector2.ZERO
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(node, "scale", Vector2.ONE, duration)
	await tween.finished

## Pulse animation
func pulse(node: Node, scale_factor: float = 1.2, duration: float = 0.3) -> void:
	var original_scale = node.scale
	var tween = create_tween()
	tween.tween_property(node, "scale", original_scale * scale_factor, duration * 0.5)
	tween.tween_property(node, "scale", original_scale, duration * 0.5)
