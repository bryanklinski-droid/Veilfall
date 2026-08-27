class_name SkillTreeData
extends Resource

@export var character_id: String
@export var skill_nodes: Array = []

## Get specific skill node
func get_skill_node(skill_id: String) -> SkillNode:
	for node in skill_nodes:
		if node.skill_id == skill_id:
			return node
	return null

## Get all skills of a certain type
func get_skills_by_type(skill_type: String) -> Array[SkillNode]:
	var results = []
	for node in skill_nodes:
		if node.skill_data.skill_type == skill_type:
			results.append(node)
	return results

class SkillNode:
	var skill_id: String
	var skill_data: SkillData
	var skill_points_cost: int = 1
	var prerequisites: Array[String] = []  # Skill IDs that must be learned first
	var tier: int = 0  # 0 = foundation, 1 = intermediate, 2 = advanced
	
	func _init(p_skill_id: String, p_skill_data: SkillData, p_cost: int = 1, p_tier: int = 0) -> void:
		skill_id = p_skill_id
		skill_data = p_skill_data
		skill_points_cost = p_cost
		tier = p_tier
