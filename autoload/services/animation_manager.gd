
extends Node

signal animation_started(character_id: String, animation_name: String)
signal animation_completed(character_id: String, animation_name: String)

var character_animations: Dictionary = {}  # {character_id: sprite_node}
var animation_timers: Dictionary = {}

## Register a character sprite for animations
func register_character(character_id: String, sprite_node: Node) -> void:
	character_animations[character_id] = sprite_node
	print("Registered character for animations: ", character_id)

## Play attack animation
func play_attack_animation(character_id: String, duration: float = 0.5) -> void:
	var sprite = character_animations.get(character_id)
	if not sprite:
		return
	
	animation_started.emit(character_id, "attack")
	
	# Create attack animation: sprite moves forward, flashes, returns
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Move forward
	tween.tween_property(sprite, "position:x", sprite.position.x + 50, duration * 0.3)
	
	# Flash white (damage effect)
	if sprite.has_method("set_self_modulate"):
		tween.tween_property(sprite, "self_modulate", Color.WHITE, duration * 0.3)
	
	tween.set_parallel(false)
	
	# Move back
	tween.tween_property(sprite, "position:x", sprite.position.x, duration * 0.4)
	
	# Restore color
	if sprite.has_method("set_self_modulate"):
		tween.tween_property(sprite, "self_modulate", Color.WHITE, 0.1)
	
	await tween.finished
	animation_completed.emit(character_id, "attack")

## Play skill animation (magical effect)
func play_skill_animation(character_id: String, skill_type: String = "magic", duration: float = 0.6) -> void:
	var sprite = character_animations.get(character_id)
	if not sprite:
		return
	
	animation_started.emit(character_id, "skill")
	
	var tween = create_tween()
	
	match skill_type:
		"magic":
			# Spin and glow
			tween.set_parallel(true)
			tween.tween_property(sprite, "rotation", TAU, duration * 0.5)
			if sprite.has_method("set_self_modulate"):
				tween.tween_property(sprite, "self_modulate", Color.YELLOW, duration * 0.5)
			tween.set_parallel(false)
			tween.tween_property(sprite, "self_modulate", Color.WHITE, 0.2)
		
		"heal":
			# Scale up with green glow
			tween.set_parallel(true)
			tween.tween_property(sprite, "scale", Vector2(1.3, 1.3), duration * 0.5)
			if sprite.has_method("set_self_modulate"):
				tween.tween_property(sprite, "self_modulate", Color.GREEN, duration * 0.5)
			tween.set_parallel(false)
			tween.tween_property(sprite, "scale", Vector2.ONE, 0.2)
			tween.tween_property(sprite, "self_modulate", Color.WHITE, 0.1)
		
		"buff":
			# Pulse and blue glow
			tween.set_parallel(true)
			tween.tween_property(sprite, "scale", Vector2(1.2, 1.2), duration * 0.3)
			if sprite.has_method("set_self_modulate"):
				tween.tween_property(sprite, "self_modulate", Color.CYAN, duration * 0.3)
			tween.set_parallel(false)
			tween.tween_property(sprite, "scale", Vector2.ONE, 0.2)
			tween.tween_property(sprite, "self_modulate", Color.WHITE, 0.1)
	
	await tween.finished
	animation_completed.emit(character_id, "skill")

## Play damage animation (knockback + red flash)
func play_damage_animation(character_id: String, _damage_amount: int = 0, duration: float = 0.4) -> void:
	var sprite = character_animations.get(character_id)
	if not sprite:
		return
	
	animation_started.emit(character_id, "damage")
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Knockback
	tween.tween_property(sprite, "position:x", sprite.position.x - 30, duration * 0.5)
	
	# Red flash
	if sprite.has_method("set_self_modulate"):
		tween.tween_property(sprite, "self_modulate", Color.RED, duration * 0.5)
	
	tween.set_parallel(false)
	
	# Return to position
	tween.tween_property(sprite, "position:x", sprite.position.x + 30, duration * 0.5)
	tween.tween_property(sprite, "self_modulate", Color.WHITE, 0.1)
	
	await tween.finished
	animation_completed.emit(character_id, "damage")

## Play defeat animation (fade out)
func play_defeat_animation(character_id: String, duration: float = 1.0) -> void:
	var sprite = character_animations.get(character_id)
	if not sprite:
		return
	
	animation_started.emit(character_id, "defeat")
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Fade and shrink
	tween.tween_property(sprite, "modulate:a", 0.0, duration)
	tween.tween_property(sprite, "scale", Vector2(0.5, 0.5), duration)
	
	await tween.finished
	animation_completed.emit(character_id, "defeat")

## Play victory animation (jump and glow)
func play_victory_animation(character_id: String, duration: float = 0.8) -> void:
	var sprite = character_animations.get(character_id)
	if not sprite:
		return
	
	animation_started.emit(character_id, "victory")
	
	var tween = create_tween()
	
	# Jump
	tween.set_parallel(true)
	tween.tween_property(sprite, "position:y", sprite.position.y - 100, duration * 0.5)
	if sprite.has_method("set_self_modulate"):
		tween.tween_property(sprite, "self_modulate", Color.YELLOW, duration * 0.5)
	tween.set_parallel(false)
	
	# Land
	tween.tween_property(sprite, "position:y", sprite.position.y + 100, duration * 0.3)
	tween.tween_property(sprite, "self_modulate", Color.WHITE, 0.1)
	
	await tween.finished
	animation_completed.emit(character_id, "victory")

## Play defend animation (shield/crouch)
func play_defend_animation(character_id: String, duration: float = 0.3) -> void:
	var sprite = character_animations.get(character_id)
	if not sprite:
		return
	
	animation_started.emit(character_id, "defend")
	
	var tween = create_tween()
	
	# Crouch
	tween.tween_property(sprite, "scale:y", 0.7, duration * 0.3)
	tween.tween_property(sprite, "scale:y", 1.0, duration * 0.3)
	
	await tween.finished
	animation_completed.emit(character_id, "defend")

## Stop all animations for character
func stop_animations(character_id: String) -> void:
	var sprite = character_animations.get(character_id)
	if sprite and sprite.is_node_processing():
		# Reset to default state
		if sprite.has_method("set_self_modulate"):
			sprite.set_self_modulate(Color.WHITE)
		sprite.scale = Vector2.ONE
		sprite.rotation = 0.0
