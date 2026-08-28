extends CharacterBody2D

@export var move_speed: float = 180.0
@onready var interaction_area: Area2D = $InteractionArea
@onready var sprite: AnimatedSprite2D = $Sprite2D

var menu_open := false
var menu_layer: CanvasLayer
var menu_panel: Panel
var facing := Vector2.DOWN

func _ready() -> void:
	_create_menu()
	_update_animation(Vector2.ZERO)

func _physics_process(_delta: float) -> void:
	if menu_open:
		velocity = Vector2.ZERO
		_update_animation(Vector2.ZERO)
		return

	var direction := Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_LEFT):
		direction.x -= 1.0
	if Input.is_physical_key_pressed(KEY_RIGHT):
		direction.x += 1.0
	if Input.is_physical_key_pressed(KEY_UP):
		direction.y -= 1.0
	if Input.is_physical_key_pressed(KEY_DOWN):
		direction.y += 1.0

	velocity = direction.normalized() * move_speed
	move_and_slide()
	_update_animation(direction)

func _update_animation(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		if abs(direction.x) > abs(direction.y):
			facing = Vector2.RIGHT if direction.x > 0.0 else Vector2.LEFT
		else:
			facing = Vector2.DOWN if direction.y > 0.0 else Vector2.UP

	if facing == Vector2.LEFT or facing == Vector2.RIGHT:
		sprite.flip_h = facing == Vector2.LEFT
		sprite.play("walk_side" if direction != Vector2.ZERO else "idle_side")
	elif facing == Vector2.UP:
		sprite.flip_h = false
		sprite.play("walk_up" if direction != Vector2.ZERO else "idle_up")
	else:
		sprite.flip_h = false
		sprite.play("walk_down" if direction != Vector2.ZERO else "idle_down")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_Z:
			interact_with_nearest()
			get_viewport().set_input_as_handled()
		elif event.physical_keycode == KEY_X:
			toggle_menu()
			get_viewport().set_input_as_handled()

func interact_with_nearest() -> void:
	if menu_open:
		return
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

func toggle_menu() -> void:
	menu_open = not menu_open
	menu_panel.visible = menu_open
	if menu_open:
		_update_menu()

func _create_menu() -> void:
	menu_layer = CanvasLayer.new()
	menu_layer.layer = 10
	add_child(menu_layer)

	menu_panel = Panel.new()
	menu_panel.position = Vector2(40, 40)
	menu_panel.size = Vector2(420, 300)
	menu_panel.visible = false
	menu_layer.add_child(menu_panel)

	var title := Label.new()
	title.position = Vector2(20, 15)
	title.text = "VEILFALL — MENU"
	title.add_theme_font_size_override("font_size", 24)
	menu_panel.add_child(title)

	var instructions := Label.new()
	instructions.name = "Instructions"
	instructions.position = Vector2(20, 60)
	instructions.size = Vector2(380, 210)
	menu_panel.add_child(instructions)

func _update_menu() -> void:
	var instructions: Label = menu_panel.get_node("Instructions")
	var companions := GameState.party.size() - 1
	instructions.text = "Party: %d companion%s\nPotions: %d\nCorruption Stage: %d\nDays Remaining: %d\n\nArrow Keys — Move\nZ — Interact\nX — Close Menu" % [companions, "" if companions == 1 else "s", InventoryManager.get_item_count("small_potion"), GameState.corruption_stage, GameState.corruption_days_remaining]
