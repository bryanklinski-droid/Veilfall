extends Node2D

@onready var player_hp_label = $UI/PlayerHPLabel
@onready var enemy_hp_label = $UI/EnemyHPLabel
@onready var message_label = $UI/MessageLabel
@onready var potion_label = $UI/PotionLabel
@export var aria: CharacterData
var player_turn = true
var battle_over = false
var player_hp = 0
var enemy_hp = 50

func _ready():
	print("Battle Started!")

	if aria != null:
		player_hp = aria.hp
		print("Base Attack:", aria.attack)
		print("Total Attack:", aria.get_attack())
	else:
		print("No CharacterData assigned to 'aria'!")

	update_hp_labels()
	update_potion_label()




func player_attack():
	enemy_hp = max(enemy_hp - aria.get_attack(), 0)

	print("You attacked!")
	print("Enemy HP:", enemy_hp)

	update_hp_labels()

	if enemy_hp <=0:
		battle_over = true
		message_label.text = "Victory"

func enemy_attack():
	var damage = max(5 - aria.get_defense(),1)
	player_hp = max(player_hp - damage, 0)
	print("Enemy attacked!")
	print("Player HP:", player_hp)
	update_hp_labels()

	if player_hp <=0:
		battle_over = true
		message_label.text = "Defeat"


func _on_attack_button_pressed():
	if battle_over:
		return
	if not player_turn:
		return

	player_turn = false

	player_attack()
	enemy_attack()

	player_turn = true


func _on_skill_button_pressed():
	print("Skill menu coming soon!")


func _on_defend_button_pressed():
	print("You Defended")


func _on_item_button_pressed():
	if GameState.potions > 0:
		player_hp = min(player_hp + 20, 100)
		GameState.potions -= 1
		update_potion_label()
		update_hp_labels()
		print("Used a Potion")
	else:
		print("No Potions Left!")

func update_potion_label():
	potion_label.text = "Potions: " + str(GameState.potions)

func update_hp_labels():
	player_hp_label.text = "Player HP: " + str(player_hp)
	enemy_hp_label.text = "Enemy HP: " + str(enemy_hp)
