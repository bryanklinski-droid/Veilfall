extends Area2D

@export var item_id: String = "cell_key"
@export var amount: int = 1
@export var chest_id: String = ""
var opened := false

func _ready() -> void:
	add_to_group("interactable")
	opened = GameState.is_chest_open(chest_id)
	_show_opened_state()

func interact() -> void:
	open_chest()

func open_chest() -> void:
	if opened:
		return
	# Never consume a chest or add phantom inventory if its reward is misconfigured.
	if amount <= 0 or not ResourceLoader.exists("res://data/items/%s.tres" % item_id):
		push_warning("Chest %s has an invalid reward: %s x %d" % [chest_id, item_id, amount])
		return

	InventoryManager.add_item(item_id, amount)
	opened = true
	if not chest_id.is_empty():
		GameState.record_chest_open(chest_id)
	else:
		SaveManager.save_game()
	print("Found ", amount, " x ", item_id)
	_show_opened_state()

func _show_opened_state() -> void:
	# The shared chest scene owns both visual states; never remove collision or
	# interaction nodes, so reloading a saved open chest remains safe.
	var closed_art := get_node_or_null("ChestArt/Closed") as CanvasItem
	var open_art := get_node_or_null("ChestArt/Open") as CanvasItem
	if closed_art != null:
		closed_art.visible = not opened
	if open_art != null:
		open_art.visible = opened
