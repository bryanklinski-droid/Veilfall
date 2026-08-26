extends Node

signal event_started(event_id: String)
signal event_completed(event_id: String)

var completed_events: Dictionary = {}
var active_event_id := ""

func start_event(event_id: String) -> bool:
	if event_id.is_empty() or active_event_id != "":
		return false
	active_event_id = event_id
	event_started.emit(event_id)
	return true

func complete_event(event_id: String = "") -> void:
	var id := event_id if not event_id.is_empty() else active_event_id
	if id.is_empty():
		return
	completed_events[id] = true
	if active_event_id == id:
		active_event_id = ""
	event_completed.emit(id)

func has_completed(event_id: String) -> bool:
	return completed_events.get(event_id, false)

func reset_events() -> void:
	completed_events.clear()
	active_event_id = ""
