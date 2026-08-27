
extends Node

signal time_changed(hour: int, minute: int)
signal day_changed(day: int)
signal cycle_changed(cycle_name: String)  # "morning", "afternoon", "evening", "night"

var current_hour: int = 6  # Start at 6 AM
var current_minute: int = 0
var current_day: int = 1
var time_scale: float = 1.0  # Multiplier for game time progression

# Time cycle thresholds
var time_cycles: Dictionary = {
	"night": [0, 6],      # 00:00 - 06:00
	"morning": [6, 12],   # 06:00 - 12:00
	"afternoon": [12, 18],# 12:00 - 18:00
	"evening": [18, 24]   # 18:00 - 24:00
}

var current_cycle: String = "morning"
var elapsed_time: float = 0.0
var time_elapsed_in_game: float = 0.0  # Track total in-game time

func _process(delta: float) -> void:
	if time_scale <= 0:
		return
	
	elapsed_time += delta * time_scale
	time_elapsed_in_game += delta * time_scale
	
	# Advance time every 6 real seconds = 1 game hour (at time_scale 1.0)
	if elapsed_time >= 6.0:
		advance_hour()
		elapsed_time = 0.0

## Advance time by one hour
func advance_hour() -> void:
	current_minute = 0
	current_hour = (current_hour + 1) % 24
	
	# New day
	if current_hour == 0:
		current_day += 1
		day_changed.emit(current_day)
	
	var old_cycle = current_cycle
	current_cycle = get_current_cycle()
	
	if old_cycle != current_cycle:
		cycle_changed.emit(current_cycle)
	
	time_changed.emit(current_hour, current_minute)
	print("Time: %02d:%02d (Day %d) - %s" % [current_hour, current_minute, current_day, current_cycle])

## Advance time by minutes
func advance_minutes(minutes: int) -> void:
	current_minute += minutes
	while current_minute >= 60:
		current_minute -= 60
		advance_hour()
	
	time_changed.emit(current_hour, current_minute)

## Set time directly
func set_time(hour: int, minute: int) -> void:
	current_hour = hour % 24
	current_minute = minute % 60
	
	var old_cycle = current_cycle
	current_cycle = get_current_cycle()
	
	if old_cycle != current_cycle:
		cycle_changed.emit(current_cycle)
	
	time_changed.emit(current_hour, current_minute)

## Get current time cycle
func get_current_cycle() -> String:
	for cycle_name in time_cycles:
		var range_data = time_cycles[cycle_name]
		var start = range_data[0]
		var end = range_data[1]
		
		if current_hour >= start and current_hour < end:
			return cycle_name
	
	return "morning"

## Get time as formatted string
func get_time_string() -> String:
	return "%02d:%02d" % [current_hour, current_minute]

## Get full date string
func get_date_string() -> String:
	return "Day %d, %s - %s" % [current_day, current_cycle.capitalize(), get_time_string()]

## Check if current time is within range
func is_time_in_range(start_hour: int, end_hour: int) -> bool:
	if start_hour < end_hour:
		return current_hour >= start_hour and current_hour < end_hour
	else:  # Range crosses midnight
		return current_hour >= start_hour or current_hour < end_hour

## Check if it's a specific cycle
func is_cycle(cycle_name: String) -> bool:
	return current_cycle == cycle_name

## Get hours until next cycle
func get_hours_until_cycle(target_cycle: String) -> int:
	var range_data = time_cycles.get(target_cycle, [0, 6])
	var next_cycle_start = range_data[0]
	
	if next_cycle_start > current_hour:
		return next_cycle_start - current_hour
	else:
		return (24 - current_hour) + next_cycle_start

## Skip to next time cycle
func skip_to_cycle(target_cycle: String) -> void:
	var range_data = time_cycles.get(target_cycle, [0, 6])
	var target_hour = range_data[0]
	
	if target_hour <= current_hour:
		target_hour += 24  # Next day
	
	var hours_to_advance = target_hour - current_hour
	for _i in range(hours_to_advance):
		advance_hour()

## Set time scale (1.0 = normal, 2.0 = 2x faster, etc)
func set_time_scale(scale: float) -> void:
	time_scale = max(0.0, scale)
	print("Time scale set to: %.1fx" % time_scale)

## Pause time
func pause_time() -> void:
	time_scale = 0.0

## Resume time
func resume_time() -> void:
	time_scale = 1.0

## Check if it's daytime
func is_daytime() -> bool:
	return current_hour >= 6 and current_hour < 18

## Check if it's nighttime
func is_nighttime() -> bool:
	return current_hour < 6 or current_hour >= 18

## Get area modifier based on time (darkness at night, brightness during day)
func get_day_night_modifier() -> float:
	if is_nighttime():
		return 0.6  # 60% brightness at night
	return 1.0  # 100% brightness during day

## Sleep until next cycle (for inn/camp rest)
func rest_until_cycle(target_cycle: String) -> void:
	pause_time()
	skip_to_cycle(target_cycle)
	resume_time()
	print("Rested until %s" % target_cycle)
