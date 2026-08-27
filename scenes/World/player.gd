extends CharacterBody2D

@export var move_speed := 200.0

func _physics_process(_delta: float) -> void:
	var direction = Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)

	velocity = direction * move_speed
	move_and_slide()
