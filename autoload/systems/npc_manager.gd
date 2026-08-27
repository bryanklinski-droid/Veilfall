extends Node


var npcs: Dictionary = {}  # npc_id -> NPCData
var active_npc: NPCData = null
var companion_event_triggers: Dictionary = {}  # companion_id -> triggered events
var corruption_events_shown: Dictionary = {}  # corruption_level -> event_shown

signal npc_interaction(npc: NPCData)
signal companion_event_triggered(npc: NPCData, companion: String)
signal corruption_event_triggered(npc: NPCData, corruption_level: int)

func _ready() -> void:
	load_all_npcs()

func load_all_npcs() -> void:
	# Load all NPC data from data/npcs/ folder
	var dir = DirAccess.open("res://data/npcs/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var npc_path = "res://data/npcs/" + file_name
				var npc = load(npc_path) as NPCData
				if npc:
					npcs[npc.npc_id] = npc
					print("Loaded NPC: ", npc.npc_id)
			file_name = dir.get_next()

func interact_with_npc(npc_id: String) -> void:
	if not npcs.has(npc_id):
		print("NPC not found: ", npc_id)
		return
	
	var npc = npcs[npc_id]
	active_npc = npc
	npc.record_interaction()
	npc_interaction.emit(npc)

## Get NPC by ID
func get_npc(npc_id: String) -> NPCData:
	return npcs.get(npc_id, null)

## Get all NPCs of a specific type
func get_npcs_by_type(npc_type: String) -> Array[NPCData]:
	var result: Array[NPCData] = []
	for npc in npcs.values():
		if npc.npc_type == npc_type:
			result.append(npc)
	return result

## Get all store keepers
func get_store_keepers() -> Array[NPCData]:
	return get_npcs_by_type("store_keeper")

## Get all quest givers
func get_quest_givers() -> Array[NPCData]:
	return get_npcs_by_type("quest_giver")

## Check and trigger companion events
func check_companion_events(companion_id: String, current_bond: int) -> NPCData:
	var companion_events = get_npcs_by_type("companion_event")
	
	for npc in companion_events:
		if npc.companion_id == companion_id and current_bond >= npc.bond_requirement:
			# Check if one-time event already triggered
			if npc.is_one_time_event and npc.event_triggered:
				continue
			
			npc.event_triggered = true
			companion_event_triggered.emit(npc, companion_id)
			return npc
	
	return null

## Check and trigger corruption events
func check_corruption_events(current_corruption: int) -> NPCData:
	var corruption_events = get_npcs_by_type("corruption_event")
	
	for npc in corruption_events:
		if current_corruption >= npc.corruption_threshold:
			# Only show each corruption event once per threshold level
			var event_key = "%s_%d" % [npc.npc_id, npc.corruption_threshold]
			if corruption_events_shown.has(event_key):
				continue
			
			corruption_events_shown[event_key] = true
			corruption_event_triggered.emit(npc, current_corruption)
			return npc
	
	return null

## Get quest giver for a specific quest
func get_quest_giver_for_quest(quest_id: String) -> NPCData:
	var quest_givers = get_quest_givers()
	for npc in quest_givers:
		if quest_id in npc.quests_offered:
			return npc
	return null

## Get shop for a store keeper
func get_shop_for_keeper(keeper_id: String) -> ShopData:
	var keeper = get_npc(keeper_id)
	if keeper and keeper.npc_type == "store_keeper" and keeper.shop_data:
		return keeper.shop_data
	return null

## Get NPC interaction count
func get_interaction_count(npc_id: String) -> int:
	var npc = get_npc(npc_id)
	if npc:
		return npc.interaction_count
	return 0
