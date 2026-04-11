extends Node2D

var path: Array = []
var path_index: int = 0
var path_progress: float = 0.0
var hp: int = 10
var max_hp: int = 10
var speed: float = 60.0
var is_dead: bool = false
var reached_end: bool = false
var game: Node2D
var enemy_type: int = 0
var gold_value: int = 3

# Visuals from config
var body_color: Color = Color(0.3, 0.7, 0.15)
var body_color_light: Color = Color(0.4, 0.85, 0.25)
var radius: float = 10.0

# Hit flash
var flash_timer: float = 0.0
const FLASH_DURATION: float = 0.12

# Slow effect
var slow_factor: float = 1.0  # 1.0 = normal speed
var slow_timer: float = 0.0
var base_speed: float = 60.0

# Sprite animation
var sprite: Sprite2D = null
var anim_timer: float = 0.0
var anim_frame: int = 0
const ANIM_SPEED: float = 0.2  # seconds per frame

# Sprite textures (loaded once, shared)
static var enemy_textures: Dictionary = {}  # EnemyType -> Texture2D

# Status effect visuals
var shock_timer: float = 0.0
const SHOCK_DURATION: float = 0.3

# Burn effect
var burn_dps: float = 0.0
var burn_timer: float = 0.0

# Sprite sheet animation
var total_frames: int = 1
var total_vframes: int = 1
var frame_timer: float = 0.0
const FRAME_SPEED: float = 0.18  # seconds per frame
var base_scale: float = 0.8
var current_dir: int = 0  # 0=down, 1=right, 2=up, 3=left

func setup(p_path: Array, p_hp: int, p_speed: float, p_game: Node2D, p_type: int = 0) -> void:
	path = p_path
	game = p_game
	enemy_type = p_type

	var config: Dictionary = GameData.ENEMY_CONFIGS[p_type]
	hp = int(p_hp * config["hp_mult"])
	max_hp = hp
	speed = p_speed * config["speed_mult"]
	base_speed = speed
	body_color = config["color"]
	body_color_light = config["color_light"]
	radius = config["radius"]
	gold_value = config["gold"]

	# Load sprite from config
	if not enemy_textures.has(enemy_type):
		var sprite_file: String = config.get("sprite", "")
		if sprite_file != "":
			enemy_textures[enemy_type] = load("res://sprites/" + sprite_file)

	var tex: Texture2D = enemy_textures.get(enemy_type, null)
	total_frames = config.get("frames", 1)
	total_vframes = config.get("vframes", 1)

	if config.get("boss", false):
		base_scale = 3.5

	if tex:
		sprite = Sprite2D.new()
		sprite.texture = tex
		sprite.hframes = total_frames
		sprite.vframes = total_vframes
		sprite.frame = 0
		sprite.scale = Vector2(base_scale, base_scale)
		add_child(sprite)
		radius = 28.0 if base_scale > 1.0 else 20.0

	if path.size() > 0:
		global_position = game.cell_to_world(path[0])
		path_index = 1

func apply_slow(factor: float, duration: float) -> void:
	slow_factor = 1.0 - factor
	slow_timer = duration

func apply_shock() -> void:
	shock_timer = SHOCK_DURATION

func apply_burn(dps: float, duration: float) -> void:
	burn_dps = dps
	burn_timer = duration

func apply_knockback(cells: int) -> void:
	path_index = max(1, path_index - cells)
	path_progress = max(0.0, path_progress - cells)
	if path_index < path.size():
		global_position = game.cell_to_world(path[path_index])

func _process(delta: float) -> void:
	if is_dead or reached_end:
		return
	if path_index >= path.size():
		reached_end = true
		return

	# Burn damage over time
	if burn_timer > 0:
		burn_timer -= delta
		hp -= int(burn_dps * delta)
		if hp <= 0:
			hp = 0
			is_dead = true
		if burn_timer <= 0:
			burn_dps = 0.0

	# Slow effect countdown
	if slow_timer > 0:
		slow_timer -= delta
		speed = base_speed * slow_factor
		if slow_timer <= 0:
			speed = base_speed
			slow_factor = 1.0

	var target: Vector2 = game.cell_to_world(path[path_index])
	var dir: Vector2 = target - global_position
	var move_dist: float = speed * delta

	if dir.length() <= move_dist:
		global_position = target
		path_index += 1
		path_progress += 1.0
	else:
		global_position += dir.normalized() * move_dist
		path_progress += move_dist / GameData.CELL_SIZE

	# Face sprite towards movement direction
	if sprite:
		var dir_n: Vector2 = dir.normalized() if dir.length() > 0.01 else Vector2.ZERO
		if total_vframes > 1 and dir_n.length() > 0:
			# 4-direction sprite: pick row based on direction
			if abs(dir_n.x) > abs(dir_n.y):
				current_dir = 1 if dir_n.x > 0 else 3
			else:
				current_dir = 0 if dir_n.y > 0 else 2
			sprite.flip_h = false
		elif dir_n.x != 0 and total_vframes <= 1:
			sprite.flip_h = dir_n.x < 0

	# Shock effect countdown
	if shock_timer > 0:
		shock_timer -= delta

	# Visual effects on sprite
	if flash_timer > 0:
		flash_timer -= delta
		if sprite:
			sprite.modulate = Color.WHITE.lerp(Color(1, 0.3, 0.3), flash_timer / FLASH_DURATION)
	elif shock_timer > 0:
		if sprite:
			# Electric shock: yellow flash with jitter
			var shock_mix: float = shock_timer / SHOCK_DURATION
			sprite.modulate = Color(1.0, 1.0, 0.5).lerp(Color.WHITE, 1.0 - shock_mix)
			sprite.offset = Vector2(randf_range(-2, 2), randf_range(-2, 2))
		else:
			pass
	elif burn_timer > 0:
		if sprite:
			# Burning: orange flicker
			var flicker: float = 0.7 + sin(burn_timer * 12.0) * 0.3
			sprite.modulate = Color(1.0, 0.5 * flicker, 0.1)
	elif slow_timer > 0:
		if sprite:
			# Frozen: blue tint + slight scale pulse
			sprite.modulate = Color(0.5, 0.7, 1.0)
			var pulse: float = 1.0 + sin(slow_timer * 8.0) * 0.05
			sprite.scale = Vector2(base_scale * pulse, base_scale * pulse)
		else:
			pass
	else:
		if sprite:
			sprite.modulate = Color.WHITE
			sprite.offset = Vector2.ZERO
			sprite.scale = Vector2(base_scale, base_scale)

	# Sprite sheet frame animation
	if sprite and total_frames > 1 and not is_dead:
		frame_timer += delta
		if frame_timer >= FRAME_SPEED:
			frame_timer -= FRAME_SPEED
			# For 4-direction sprites: frame = row * hframes + column
			var col: int = (sprite.frame % total_frames + 1) % total_frames
			sprite.frame = current_dir * total_frames + col

	queue_redraw()

func take_damage(amount: int) -> void:
	if is_dead:
		return
	hp -= amount
	flash_timer = FLASH_DURATION
	get_node("/root/Audio").play_sfx("hit", -8.0)

	# Floating damage number
	var dmg: Node2D = Node2D.new()
	dmg.set_script(load("res://scripts/damage_number.gd"))
	game.add_child(dmg)
	dmg.setup(str(amount), global_position + Vector2(randf_range(-8, 8), -radius - 4))

	if hp <= 0:
		hp = 0
		is_dead = true
		var tween: Tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.1)
		tween.tween_property(self, "scale", Vector2(0.0, 0.0), 0.15)
		tween.parallel().tween_property(self, "modulate:a", 0.0, 0.15)

func _draw() -> void:
	# Ground shadow
	if not is_dead:
		draw_circle(Vector2(2, 8), radius * 0.9, Color(0, 0, 0, 0.2))

	# Burn fire particles
	if burn_timer > 0:
		var t: float = Time.get_ticks_msec() / 1000.0
		for i in range(3):
			var fx: float = sin(t * 5.0 + i * 2.0) * 6
			var fy: float = -8 - abs(sin(t * 7.0 + i * 1.5)) * 10
			var alpha: float = 0.5 + sin(t * 8.0 + i) * 0.3
			draw_circle(Vector2(fx, fy), 3.0, Color(1.0, 0.6, 0.0, alpha))
			draw_circle(Vector2(fx * 0.5, fy - 4), 2.0, Color(1.0, 0.9, 0.2, alpha * 0.6))

	# Status effect overlays (drawn on top of sprite)
	if slow_timer > 0:
		# Frozen: draw ice crystals around character
		var ice_color: Color = Color(0.6, 0.85, 1.0, 0.6)
		draw_circle(Vector2(-12, -8), 4, ice_color)
		draw_circle(Vector2(10, -5), 3, ice_color)
		draw_circle(Vector2(-5, 10), 3.5, ice_color)
		draw_circle(Vector2(8, 8), 2.5, ice_color)
		# Ice border around character
		draw_arc(Vector2.ZERO, radius + 4, 0, TAU, 16, Color(0.5, 0.8, 1.0, 0.4), 2.0)

	if shock_timer > 0:
		# Electric: draw lightning bolts
		var spark_color: Color = Color(1.0, 1.0, 0.3, shock_timer / SHOCK_DURATION)
		var t: float = shock_timer * 20.0
		for i in range(4):
			var angle: float = t + i * TAU / 4
			var from: Vector2 = Vector2(cos(angle) * 8, sin(angle) * 8)
			var mid: Vector2 = Vector2(cos(angle + 0.3) * 16, sin(angle + 0.3) * 16)
			var to: Vector2 = Vector2(cos(angle + 0.1) * 22, sin(angle + 0.1) * 22)
			draw_line(from, mid, spark_color, 2.0)
			draw_line(mid, to, spark_color, 1.5)

	# HP bar
	_draw_hp_bar()

func _draw_hp_bar() -> void:
	var is_boss_unit: bool = base_scale > 1.0
	if hp >= max_hp and not is_boss_unit:
		return
	var w: float = base_scale * 50.0 if is_boss_unit else radius * 2.4
	var h: float = 8.0 if is_boss_unit else 3.0
	# Boss HP bar below feet, normal enemies above head
	var bar_y: float = base_scale * 32.0 + 5.0 if is_boss_unit else -radius - 7
	draw_rect(Rect2(-w / 2, bar_y, w, h), Color(0.15, 0.15, 0.15))
	var ratio: float = float(hp) / float(max_hp)
	var bar_color: Color
	if ratio > 0.5:
		bar_color = Color(0.2, 0.8, 0.2)
	elif ratio > 0.25:
		bar_color = Color(0.8, 0.7, 0.1)
	else:
		bar_color = Color(0.9, 0.2, 0.2)
	draw_rect(Rect2(-w / 2, bar_y, w * ratio, h), bar_color)
