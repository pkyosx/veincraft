extends Node

# SFX players — pool for concurrent sounds
var sfx_pool: Array = []
const SFX_POOL_SIZE: int = 8
var pool_index: int = 0

# Preloaded sfxr streams
var streams: Dictionary = {}

# BGM
var bgm_player: AudioStreamPlayer
var bgm_playing: bool = false
var bgm_sample_pos: float = 0.0  # running sample position for clean phase
const BGM_SAMPLE_RATE: float = 22050.0

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

	bgm_player = AudioStreamPlayer.new()
	bgm_player.bus = "Master"
	bgm_player.volume_db = -12.0
	add_child(bgm_player)

	_setup_bgm()

func play_sfx(name: String, volume_offset: float = 0.0) -> void:
	if name not in streams:
		return
	var player: AudioStreamPlayer = sfx_pool[pool_index]
	pool_index = (pool_index + 1) % SFX_POOL_SIZE
	player.stream = streams[name]
	player.volume_db = -6.0 + volume_offset
	player.pitch_scale = randf_range(0.9, 1.1)
	player.play()

func _setup_bgm() -> void:
	var generator: AudioStreamGenerator = AudioStreamGenerator.new()
	generator.mix_rate = BGM_SAMPLE_RATE
	generator.buffer_length = 0.5
	bgm_player.stream = generator
	bgm_player.play()
	bgm_playing = true
	bgm_sample_pos = 0.0

func _process(_delta: float) -> void:
	if not bgm_playing:
		return
	var playback: AudioStreamGeneratorPlayback = bgm_player.get_stream_playback()
	if playback == null:
		return

	var frames: int = playback.get_frames_available()
	if frames <= 0:
		return

	for i in range(frames):
		var sample: float = _bgm_sample(bgm_sample_pos)
		playback.push_frame(Vector2(sample, sample))
		bgm_sample_pos += 1.0

# === BGM Synthesis ===
# Simple chiptune-style melody + bass + drums

# Note frequencies (A minor pentatonic for melody)
const MELODY_NOTES: Array[float] = [220.0, 261.6, 293.7, 329.6, 392.0, 440.0, 523.3, 587.3]
const BASS_NOTES: Array[float] = [55.0, 65.4, 73.4, 82.4]  # A C D E (low octave)

func _bgm_sample(pos: float) -> float:
	var t: float = pos / BGM_SAMPLE_RATE  # time in seconds
	var bpm: float = 100.0
	var beat: float = t * bpm / 60.0
	var bar: float = beat / 4.0  # 4 beats per bar
	var beat_in_bar: float = fmod(beat, 4.0)

	var out: float = 0.0

	# --- Kick drum on beats 0 and 2 ---
	var kick_beat: float = fmod(beat, 2.0)
	var kick_env: float = maxf(0.0, 1.0 - kick_beat * 5.0)
	var kick_freq: float = 60.0 * (1.0 + kick_env * 2.0)  # pitch drops
	out += sin(pos / BGM_SAMPLE_RATE * kick_freq * TAU) * kick_env * 0.15

	# --- Hi-hat on every half beat ---
	var hat_beat: float = fmod(beat * 2.0, 1.0)
	var hat_env: float = maxf(0.0, 1.0 - hat_beat * 12.0)
	# Simple noise approximation
	var noise: float = fmod(sin(pos * 127.1) * 43758.5453, 1.0) * 2.0 - 1.0
	out += noise * hat_env * 0.03

	# --- Bass line (square wave, changes every bar) ---
	var bass_idx: int = int(fmod(bar, BASS_NOTES.size()))
	var bass_freq: float = BASS_NOTES[bass_idx]
	var bass_phase: float = fmod(pos * bass_freq / BGM_SAMPLE_RATE, 1.0)
	var bass_wave: float = 1.0 if bass_phase < 0.5 else -1.0
	# Bass plays on first 3 beats of each bar
	var bass_env: float = 1.0 if beat_in_bar < 3.0 else 0.0
	out += bass_wave * 0.06 * bass_env

	# --- Melody (triangle wave, simple repeating pattern) ---
	# 8-note pattern over 2 bars
	var melody_step: int = int(fmod(beat, 8.0))
	var melody_pattern: Array[int] = [0, 2, 4, 5, 4, 2, 3, 1]
	var melody_freq: float = MELODY_NOTES[melody_pattern[melody_step]]
	var melody_phase: float = fmod(pos * melody_freq / BGM_SAMPLE_RATE, 1.0)
	# Triangle wave
	var melody_wave: float = abs(melody_phase * 4.0 - 2.0) - 1.0
	# Envelope: note on for 80% of beat
	var note_pos: float = fmod(beat, 1.0)
	var melody_env: float = maxf(0.0, 1.0 - maxf(0.0, note_pos - 0.7) * 10.0)
	out += melody_wave * 0.07 * melody_env

	# --- Pad (soft sine chord, very quiet) ---
	out += sin(pos * 110.0 / BGM_SAMPLE_RATE * TAU) * 0.02
	out += sin(pos * 164.8 / BGM_SAMPLE_RATE * TAU) * 0.015

	return clampf(out, -0.9, 0.9)
