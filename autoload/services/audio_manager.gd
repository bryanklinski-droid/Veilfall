
extends Node

const MUSIC_FADE_DURATION = 1.0
const SFX_POOL_SIZE = 8

var music_player: AudioStreamPlayer = null
var sfx_players: Array[AudioStreamPlayer] = []
var current_music: String = ""
var is_fading: bool = false

func _ready() -> void:
	# Create music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)
	
	# Create SFX pool
	for i in range(SFX_POOL_SIZE):
		var sfx_player = AudioStreamPlayer.new()
		sfx_player.bus = "SFX"
		add_child(sfx_player)
		sfx_players.append(sfx_player)

## Play music with fade in/out
func play_music(music_path: String, fade_in: bool = true) -> void:
	if current_music == music_path and music_player.playing:
		return  # Already playing
	
	if not ResourceLoader.exists(music_path):
		print("Warning: Music file not found: ", music_path)
		return
	
	if music_player.playing and fade_in:
		_fade_out_music()
		await get_tree().create_timer(MUSIC_FADE_DURATION).timeout
	
	var audio = load(music_path)
	music_player.stream = audio
	music_player.play()
	current_music = music_path
	
	if fade_in:
		_fade_in_music()

## Stop music
func stop_music(fade_out: bool = true) -> void:
	if not music_player.playing:
		return
	
	if fade_out:
		_fade_out_music()
		await get_tree().create_timer(MUSIC_FADE_DURATION).timeout
	
	music_player.stop()
	current_music = ""

## Play sound effect
func play_sfx(sfx_path: String, volume_db: float = 0.0) -> void:
	if not ResourceLoader.exists(sfx_path):
		print("Warning: SFX file not found: ", sfx_path)
		return
	
	# Find available player
	var player = _get_available_sfx_player()
	if not player:
		print("Warning: No SFX players available")
		return
	
	var audio = load(sfx_path)
	player.stream = audio
	player.volume_db = volume_db
	player.play()

## Play UI sound (generic click, hover, etc)
func play_ui_sound(sound_type: String) -> void:
	match sound_type:
		"click":
			play_sfx("res://assets/audio/ui_click.ogg", -5.0)
		"hover":
			play_sfx("res://assets/audio/ui_hover.ogg", -10.0)
		"error":
			play_sfx("res://assets/audio/ui_error.ogg", -5.0)

## Play battle sound effect
func play_battle_sound(sound_type: String) -> void:
	match sound_type:
		"attack":
			play_sfx("res://assets/audio/battle_attack.ogg")
		"hit":
			play_sfx("res://assets/audio/battle_hit.ogg")
		"heal":
			play_sfx("res://assets/audio/battle_heal.ogg")
		"defend":
			play_sfx("res://assets/audio/battle_defend.ogg")
		"skill":
			play_sfx("res://assets/audio/battle_skill.ogg")

## Set master volume
func set_master_volume(volume: float) -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), volume <= -80.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume)

## Set music volume
func set_music_volume(volume: float) -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), volume <= -80.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), volume)

## Set SFX volume
func set_sfx_volume(volume: float) -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), volume <= -80.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), volume)

## Get available SFX player
func _get_available_sfx_player() -> AudioStreamPlayer:
	for player in sfx_players:
		if not player.playing:
			return player
	
	# If all busy, reuse the oldest one
	return sfx_players[0]

## Fade in music
func _fade_in_music() -> void:
	if is_fading:
		return
	
	is_fading = true
	music_player.volume_db = -80.0
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", 0.0, MUSIC_FADE_DURATION)
	await tween.finished
	is_fading = false

## Fade out music
func _fade_out_music() -> void:
	if is_fading:
		return
	
	is_fading = true
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", -80.0, MUSIC_FADE_DURATION)
	await tween.finished
	is_fading = false
