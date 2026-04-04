extends Node

# SFX players — pool for concurrent sounds
var sfx_pool: Array = []
const SFX_POOL_SIZE: int = 8
var pool_index: int = 0

# Preloaded streams
var streams: Dictionary = {}

# BGM
var bgm_player: AudioStreamPlayer

func _ready() -> void:
	for i in range(SFX_POOL_SIZE):
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.bus = "Master"
		player.volume_db = -6.0
		add_child(player)
		sfx_pool.append(player)

	streams["shoot"] = load("res://audio/sfx_shoot.tres")
	streams["hit"] = load("res://audio/sfx_hit.tres")
	streams["kill"] = load("res://audio/sfx_kill.tres")
	streams["tick"] = load("res://audio/sfx_tick.tres")
	streams["jackpot"] = load("res://audio/sfx_jackpot.tres")
	streams["treasure"] = load("res://audio/sfx_treasure.tres")
	streams["warn"] = load("res://audio/sfx_warn.tres")
	streams["place"] = load("res://audio/sfx_place.tres")

	# BGM from file
	bgm_player = AudioStreamPlayer.new()
	bgm_player.bus = "Master"
	bgm_player.volume_db = -10.0
	add_child(bgm_player)
	var bgm_stream: AudioStream = load("res://audio/bgm.mp3")
	if bgm_stream:
		bgm_player.stream = bgm_stream
		bgm_player.play()
		# Loop when finished
		bgm_player.finished.connect(func() -> void: bgm_player.play())

func play_sfx(name: String, volume_offset: float = 0.0) -> void:
	if name not in streams:
		return
	var player: AudioStreamPlayer = sfx_pool[pool_index]
	pool_index = (pool_index + 1) % SFX_POOL_SIZE
	player.stream = streams[name]
	player.volume_db = -6.0 + volume_offset
	player.pitch_scale = randf_range(0.9, 1.1)
	player.play()
