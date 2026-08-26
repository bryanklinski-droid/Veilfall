extends Node

const MAX_CORRUPTION_STAGE := 5
const CORRUPTION_STAT_PENALTY := 0.1
const DEFAULT_DAYS := 7

signal corruption_changed(stage: int, days_remaining: int)
signal hero_captured

func start_corruption() -> void:
	GameState.corruption_days_remaining = DEFAULT_DAYS
	set_stage(1)

func set_stage(stage: int) -> void:
	GameState.corruption_stage = clampi(stage, 0, MAX_CORRUPTION_STAGE)
	corruption_changed.emit(GameState.corruption_stage, GameState.corruption_days_remaining)

func advance_day(days: int = 1) -> void:
	if days <= 0 or GameState.corruption_days_remaining <= 0:
		return
	GameState.corruption_days_remaining = maxi(GameState.corruption_days_remaining - days, 0)
	if GameState.corruption_days_remaining == 0:
		capture_hero()
	else:
		corruption_changed.emit(GameState.corruption_stage, GameState.corruption_days_remaining)

func register_defeat(had_companions: bool, while_escaping: bool = false) -> void:
	if not had_companions:
		GameState.companionless_defeats += 1
		GameState.consecutive_companion_defeats = 0
		capture_hero()
		return

	GameState.consecutive_companion_defeats += 1
	if GameState.consecutive_companion_defeats >= 3:
		capture_hero()
		return

	if while_escaping:
		GameState.escape_defeats += 1
		advance_day(1)

func register_victory() -> void:
	GameState.consecutive_companion_defeats = 0

func capture_hero() -> void:
	if GameState.hero_captured:
		return
	GameState.hero_captured = true
	GameState.corruption_days_remaining = 0
	hero_captured.emit()
