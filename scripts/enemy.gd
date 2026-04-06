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

# Slime bounce animation
var bounce_phase: float = 0.0
const BOUNCE_SPEED: float = 6.0  # hops per second
var is_slime: bool = false

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
	is_slime = config.get("name", "") == "Slime" or config.get("name", "") == "Mushroom"

	if tex:
		sprite = Sprite2D.new()
		sprite.texture = tex
		sprite.hframes = 1
		sprite.frame = 0
		sprite.scale = Vector2(1.2, 1.2)
		add_child(sprite)
		radius = 20.0

	if path.size() > 0:
		global_position = game.cell_to_world(path[0])
		path_index = 1

func apply_slow(factor: float, duration: float) -> void:
	slow_factor = 1.0 - factor
	slow_timer = duration

func apply_shock() -> void:
	shock_timer = SHOCK_DURATION

func _process(delta: float) -> void:
	if is_dead or reached_end:
		return
	if path_index >= path.size():
		reached_end = true
		return

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

	# Flip sprite based on movement direction
	if sprite and dir.x != 0:
		sprite.flip_h = dir.x < 0

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
	elif slow_timer > 0:
		if sprite:
			# Frozen: blue tint + slight scale pulse
			sprite.modulate = Color(0.5, 0.7, 1.0)
			var pulse: float = 1.0 + sin(slow_timer * 8.0) * 0.05
			sprite.scale = Vector2(1.2 * pulse, 1.2 * pulse)
		else:
			pass
	else:
		if sprite:
			sprite.modulate = Color.WHITE
			sprite.offset = Vector2.ZERO
			sprite.scale = Vector2(1.2, 1.2)

	# Slime squash & stretch bounce
	if sprite and is_slime and not is_dead:
		bounce_phase += delta * BOUNCE_SPEED * TAU
		# Use sin for smooth cycle: 0=ground, PI/2=peak, PI=ground
		var t: float = sin(bounce_phase)  # -1 to 1
		var abs_t: float = abs(t)
		# Jump height (vertical offset)
		var hop_height: float = abs_t * 12.0
		# Squash/stretch: when on ground (t near 0) = squash, when airborne = stretch
		var squash: float
		var stretch: float
		if abs_t < 0.3:
			# Ground contact: squash wide & flat
			var ground_mix: float = 1.0 - abs_t / 0.3
			squash = 1.2 * (1.0 + ground_mix * 0.25)   # wider
			stretch = 1.2 * (1.0 - ground_mix * 0.2)    # shorter
		else:
			# Airborne: stretch tall & narrow
			var air_mix: float = (abs_t - 0.3) / 0.7
			squash = 1.2 * (1.0 - air_mix * 0.15)       # narrower
			stretch = 1.2 * (1.0 + air_mix * 0.2)        # taller
		sprite.scale = Vector2(squash, stretch)
		sprite.offset = Vector2(sprite.offset.x, -hop_height)

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
	if hp >= max_hp:
		return
	var w: float = radius * 2.4
	var h: float = 3.0
	var bar_y: float = -radius - 7
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
