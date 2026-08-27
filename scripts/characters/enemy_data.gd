class_name EnemyData
extends CharacterData

@export var experience_reward: int = 25
@export var gold_reward: int = 10
@export var loot_table: Array[String] = []
@export var loot_chances: Array[float] = []

func get_random_loot() -> Dictionary:
	"""Returns a dictionary of items this enemy might drop"""
	var loot = {}
	
	if loot_table.is_empty():
		return loot
	
	for i in range(loot_table.size()):
		if i < loot_chances.size() and randf() < loot_chances[i]:
			var item_id = loot_table[i]
			loot[item_id] = loot.get(item_id, 0) + 1
	
	return loot
