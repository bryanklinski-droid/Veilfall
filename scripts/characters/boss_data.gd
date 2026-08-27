class_name BossData
extends EnemyData

## Boss-specific mechanics and rewards

@export var phase_thresholds: Array[int] = [100, 50]  # HP thresholds for phase changes
@export var phase_abilities: Array[Array] = []  # Abilities available in each phase
@export var is_story_boss: bool = false  # Affects story progression
@export var boss_rewards: Dictionary = {
	"experience": 500,
	"gold": 1000,
	"items": {}
}

var current_phase: int = 0

func get_current_phase() -> int:
	var hp_percent = (float(hp) / float(max_hp)) * 100.0
	
	for i in range(phase_thresholds.size()):
		if hp_percent <= phase_thresholds[i]:
			current_phase = i + 1
			return current_phase
	
	return 0  # Phase 0 (default)

## Get abilities available in current phase
func get_phase_abilities() -> Array[SkillData]:
	var phase = get_current_phase()
	if phase < phase_abilities.size():
		return phase_abilities[phase]
	return []

## Boss enters next phase
func advance_phase() -> void:
	current_phase += 1
	# Could trigger special effects here
	print("%s enters phase %d!" % [display_name, current_phase + 1])
	# TODO: trigger phase change animation/dialogue

## Boss should use special ability in this phase
func should_use_phase_ability() -> bool:
	return randf() < 0.3  # 30% chance per turn

## Get boss description (for UI display)
func get_boss_description() -> String:
	return "%s\nHP: %d/%d\nLevel: %d\nPhase: %d/%d" % [
		display_name,
		hp,
		max_hp,
		level,
		current_phase + 1,
		phase_thresholds.size() + 1
	]
