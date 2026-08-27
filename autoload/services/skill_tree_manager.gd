
extends Node

@warning_ignore("unused_signal")
signal skill_tree_loaded(character_id: String, tree: SkillTreeData)
signal skill_unlocked(character_id: String, skill_id: String)
signal skill_upgraded(character_id: String, skill_id: String, level: int)

var skill_trees: Dictionary = {}  # {character_id: SkillTreeData}
var character_progress: Dictionary = {}  # {character_id: {skill_id: points_invested}}

func _ready() -> void:
	load_skill_trees()

## Load all skill trees from data directory
func load_skill_trees() -> void:
	var dir = DirAccess.open("res://data/skill_trees/")
	if dir:
		dir.list_dir_begin()
		var filename = dir.get_next()
		while filename != "":
			if filename.ends_with(".tres"):
				var char_id = filename.trim_suffix(".tres")
				var tree = load("res://data/skill_trees/" + filename)
				if tree is SkillTreeData:
					skill_trees[char_id] = tree
					character_progress[char_id] = {}
			filename = dir.get_next()
	
	print("Loaded %d skill trees" % skill_trees.size())

## Get skill tree for character
func get_skill_tree(character_id: String) -> SkillTreeData:
	return skill_trees.get(character_id)

## Check if skill is unlocked for character
func is_skill_unlocked(character_id: String, skill_id: String) -> bool:
	if not character_progress.has(character_id):
		return false
	
	var progress = character_progress[character_id]
	return progress.get(skill_id, 0) > 0

## Get points invested in skill
func get_skill_points(character_id: String, skill_id: String) -> int:
	if not character_progress.has(character_id):
		return 0
	return character_progress[character_id].get(skill_id, 0)

## Invest points in skill (requires skill points)
func invest_in_skill(character_id: String, skill_id: String, points: int = 1) -> bool:
	if not skill_trees.has(character_id):
		return false
	
	var tree = skill_trees[character_id]
	var skill_node = tree.get_skill_node(skill_id)
	if not skill_node:
		return false
	
	# Check prerequisites
	if not can_invest_in_skill(character_id, skill_id):
		print("Prerequisites not met for skill: ", skill_id)
		return false
	
	# Check if character has enough skill points
	var character_data = GameState.get_party_member(character_id)
	if not character_data:
		return false
	
	var available_points = character_data.skill_points
	if available_points < points:
		print("Not enough skill points!")
		return false
	
	# Invest points
	if not character_progress[character_id].has(skill_id):
		character_progress[character_id][skill_id] = 0
	
	character_progress[character_id][skill_id] += points
	character_data.skill_points -= points
	
	# Learn skill if first point invested
	if character_progress[character_id][skill_id] == points:
		character_data.learn_skill(skill_node.skill_data)
		skill_unlocked.emit(character_id, skill_id)
	
	skill_upgraded.emit(character_id, skill_id, character_progress[character_id][skill_id])
	print("Invested %d points in skill: %s" % [points, skill_id])
	SaveManager.save_game()
	return true

## Check if prerequisites for skill are met
func can_invest_in_skill(character_id: String, skill_id: String) -> bool:
	if not skill_trees.has(character_id):
		return false
	
	var tree = skill_trees[character_id]
	var skill_node = tree.get_skill_node(skill_id)
	if not skill_node:
		return false
	
	# Check if prerequisites are unlocked
	for prereq_id in skill_node.prerequisites:
		if not is_skill_unlocked(character_id, prereq_id):
			return false
	
	return true

## Get available skills to unlock
func get_available_skills(character_id: String) -> Array[Dictionary]:
	if not skill_trees.has(character_id):
		return []
	
	var tree = skill_trees[character_id]
	var available = []
	
	for skill_node in tree.skill_nodes:
		if not is_skill_unlocked(character_id, skill_node.skill_id):
			if can_invest_in_skill(character_id, skill_node.skill_id):
				available.append({
					"id": skill_node.skill_id,
					"name": skill_node.skill_data.skill_name,
					"description": skill_node.skill_data.description,
					"cost": skill_node.skill_points_cost
				})
	
	return available

## Get skill tree progress display
func get_character_skill_progress(character_id: String) -> Dictionary:
	if not character_progress.has(character_id):
		return {}
	
	return character_progress[character_id].duplicate()
