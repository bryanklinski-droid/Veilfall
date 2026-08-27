class_name PlayerController
extends CharacterBody2D

@export var speed: float = 200.0
@export var acceleration: float = 1500.0
@export var friction: float = 1000.0

var current_direction: Vector2 = Vector2.ZERO
var is_moving: bool = false

func _physics_process(delta: float) -> void:
	var input_direction = _get_input_direction()
	
	# Update velocity with acceleration/friction
	if input_direction != Vector2.ZERO:
		velocity = velocity.move_toward(input_direction * speed, acceleration * delta)
		is_moving = true
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		is_moving = false
	
	# Move the character
	move_and_slide()
	current_direction = input_direction

func _get_input_direction() -> Vector2:
	var direction = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	
	return direction.normalized()

func set_position_safe(new_position: Vector2) -> void:
	"""Teleport player to a position (for transitions)"""
	global_position = new_position
	velocity = Vector2.ZERO
