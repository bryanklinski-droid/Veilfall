extends CharacterBody2D

@export var move_speed: float = 180.0
@onready var interaction_area: Area2D = $InteractionArea

func _physics_process(_delta: float) -> void:
	var direction := Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_A):
		direction.x -= 1.0
	if Input.is_physical_key_pressed(KEY_D):
		direction.x += 1.0
	if Input.is_physical_key_pressed(KEY_W):
		direction.y -= 1.0
	if Input.is_physical_key_pressed(KEY_S):
		direction.y += 1.0

	velocity = direction.normalized() * move_speed
	move_and_slide()

	if Input.is_physical_key_pressed(KEY_E):
		interact_with_nearest()

func interact_with_nearest() -> void:
	var nearest: Node = null
	var nearest_distance := INF
	for area in interaction_area.get_overlapping_areas():
		if not area.is_in_group("interactable"):
			continue
		var distance := global_position.distance_squared_to(area.global_position)
		if distance < nearest_distance:
			nearest = area
			nearest_distance = distance

	if nearest != null and nearest.has_method("interact"):
		nearest.interact()
