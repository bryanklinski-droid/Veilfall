extends Node2D

@onready var player_hp_label: Label = $UI/PlayerHPLabel
@onready var enemy_hp_label: Label = $UI/EnemyHPLabel
@onready var message_label: Label = $UI/MessageLabel
@onready var potion_label: Label = $UI/PotionLabel
@export var aria: CharacterData
@export var is_boss_battle := false

var player_turn := true
var battle_over := false
var defending := false
var player_hp := 0
var enemy_hp := 50

func _ready() -> void:
	print("Battle Started!")
	if aria == null:
		battle_over = true
		message_label.text = "Battle Error: No player character assigned."
		update_hp_labels()
		update_potion_label()
		return
	player_hp = clampi(aria.hp, 0, aria.max_hp)
	update_hp_labels()
	update_potion_label()

func player_attack() -> void:
	if aria == null or battle_over:
		return
	enemy_hp = maxi(enemy_hp - aria.get_attack(), 0)
	print("You attacked! Enemy HP:", enemy_hp)
	if enemy_hp <= 0:
		end_battle(true)
	else:
		end_player_turn()
	update_hp_labels()

func enemy_attack() -> void:
	if aria == null or battle_over:
		return
	var damage := maxi(5 - aria.get_defense(), 1)
	if defending:
		damage = maxi(1, int(damage * 0.5))
	defending = false
	player_hp = maxi(player_hp - damage, 0)
	print("Enemy attacked! Player HP:", player_hp)
	if player_hp <= 0:
		end_battle(false)
	update_hp_labels()

func end_player_turn() -> void:
	player_turn = false
	enemy_attack()
	if not battle_over:
		player_turn = true

func end_battle(victory: bool) -> void:
	battle_over = true
	player_turn = false
	if is_boss_battle:
		if victory:
			CorruptionManager.register_victory()
		else:
			CorruptionManager.register_defeat(GameState.party.size() > 1)
	message_label.text = "Victory" if victory else "Defeat"

func _on_attack_button_pressed() -> void:
	if battle_over or not player_turn or aria == null:
		return
	player_attack()

func _on_skill_button_pressed() -> void:
	if battle_over or not player_turn:
		return
	message_label.text = "Skill menu coming soon!"

func _on_defend_button_pressed() -> void:
	if battle_over or not player_turn:
		return
	defending = true
	message_label.text = "Defending"
	end_player_turn()

func _on_item_button_pressed() -> void:
	if battle_over or not player_turn or aria == null:
		return
	var item_id := "small_potion"
	if not InventoryManager.has_item(item_id):
		message_label.text = "No Potions Left!"
		return

	if not InventoryManager.remove_item(item_id, 1):
		message_label.text = "No Potions Left!"
		return
	player_hp = mini(player_hp + 50, aria.max_hp)
	message_label.text = "Used a Potion"
	update_potion_label()
	update_hp_labels()
	end_player_turn()

func update_potion_label() -> void:
	potion_label.text = "Potions: " + str(InventoryManager.get_item_count("small_potion"))

func update_hp_labels() -> void:
	player_hp_label.text = "Player HP: %d / %d" % [player_hp, aria.max_hp if aria != null else 0]
	enemy_hp_label.text = "Enemy HP: " + str(enemy_hp)
