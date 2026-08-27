
extends CanvasLayer

## Manages screen transitions and scene polish animations
## Provides fade, slide, and dissolve effects

signal transition_started(type: String)
signal transition_completed(type: String)

var fade_rect: ColorRect
var is_transitioning: bool = false

func _ready() -> void:
	# Create fade overlay rectangle
	fade_rect = ColorRect.new()
	fade_rect.color = Color.BLACK
	fade_rect.anchor_right = 1.0
	fade_rect.anchor_bottom = 1.0
	fade_rect.modulate.a = 0.0  # Start transparent
	add_child(fade_rect)
	
	print("TransitionManager ready - fade transitions available")

## Fade to black and back
func fade_in(duration: float = 0.5) -> void:
	if is_transitioning:
		return
	
	is_transitioning = true
	transition_started.emit("fade_in")
	
	# Fade in from black
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(fade_rect, "modulate:a", 0.0, duration)
	
	await tween.finished
	is_transitioning = false
	transition_completed.emit("fade_in")

## Fade to black
func fade_out(duration: float = 0.5) -> void:
	if is_transitioning:
		return
	
	is_transitioning = true
	transition_started.emit("fade_out")
	
	# Fade to black
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(fade_rect, "modulate:a", 1.0, duration)
	
	await tween.finished
	is_transitioning = false
	transition_completed.emit("fade_out")

## Fade transition: out then in (useful for scene changes)
func fade_transition(duration: float = 0.5) -> void:
	await fade_out(duration / 2.0)
	await fade_in(duration / 2.0)

## Slide transition (slide from one direction)
func slide_transition(from_direction: Vector2 = Vector2.RIGHT, duration: float = 0.4) -> void:
	if is_transitioning:
		return
	
	is_transitioning = true
	transition_started.emit("slide")
	
	# Create a slide panel
	var slide_panel = Panel.new()
	slide_panel.anchor_right = 1.0
	slide_panel.anchor_bottom = 1.0
	slide_panel.self_modulate.a = 0.8
	add_child(slide_panel)
	
	# Position off-screen based on direction
	var start_pos = from_direction * get_viewport().get_visible_rect().size
	slide_panel.position = start_pos
	
	# Slide in and out
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(slide_panel, "position", Vector2.ZERO, duration / 2.0)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(slide_panel, "position", -start_pos, duration / 2.0)
	
	await tween.finished
	slide_panel.queue_free()
	is_transitioning = false
	transition_completed.emit("slide")

## Smooth fade and position transition for UI panels
func animate_panel_show(panel: Control, duration: float = 0.3, from_offset: Vector2 = Vector2(0, 20)) -> void:
	panel.modulate.a = 0.0
	panel.position += from_offset
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	
	tween.tween_property(panel, "modulate:a", 1.0, duration)
	tween.tween_property(panel, "position", panel.position - from_offset, duration)
	
	await tween.finished

## Smooth fade and position transition for hiding UI panels
func animate_panel_hide(panel: Control, duration: float = 0.3, to_offset: Vector2 = Vector2(0, 20)) -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	tween.set_parallel(true)
	
	tween.tween_property(panel, "modulate:a", 0.0, duration)
	tween.tween_property(panel, "position", panel.position + to_offset, duration)
	
	await tween.finished
	panel.hide()

## Bounce animation for emphasis
func bounce_animation(node: Node, duration: float = 0.3, magnitude: float = 10.0) -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_ease(Tween.EASE_OUT)
	
	if node is Control:
		tween.tween_property(node, "position:y", node.position.y - magnitude, duration / 2.0)
		tween.tween_property(node, "position:y", node.position.y, duration / 2.0)

## Pulse animation (scale and fade)
func pulse_animation(node: Node, duration: float = 0.2, scale_factor: float = 1.1) -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_parallel(true)
	
	if node is CanvasItem:
		tween.tween_property(node, "scale", Vector2.ONE * scale_factor, duration / 2.0)
		tween.tween_callback(func():
			var tween2 = create_tween()
			tween2.set_trans(Tween.TRANS_CUBIC)
			tween2.tween_property(node, "scale", Vector2.ONE, duration / 2.0)
		)

## Text typewriter effect
func typewriter_effect(label: Label, text: String, speed: float = 0.05) -> void:
	label.text = ""
	for letter in text:
		label.text += letter
		await get_tree().create_timer(speed).timeout

## Menu navigation highlight
func highlight_menu_item(item: Control, is_highlighted: bool = true, duration: float = 0.2) -> void:
	var target_modulate = Color.WHITE if is_highlighted else Color(0.7, 0.7, 0.7)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(item, "self_modulate", target_modulate, duration)
