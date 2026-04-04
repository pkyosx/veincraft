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
static var pumpkin_texture: Texture2D = null
static var enemy_textures: Dictionary = {}  # EnemyType -> Texture2D
static var enemy_hframes: Dictionary = {}   # EnemyType -> int

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

	# Setup sprites for all enemy types
	if enemy_textures.is_empty():
		enemy_textures[GameData.EnemyType.NORMAL] = load("res://sprites/enemy_normal.png")
		enemy_textures[GameData.EnemyType.FAST] = load("res://sprites/enemy_fast.png")
		enemy_textures[GameData.EnemyType.TANK] = load("res://sprites/enemy_tank.png")
		enemy_hframes[GameData.EnemyType.NORMAL] = 6
		enemy_hframes[GameData.EnemyType.FAST] = 4
		enemy_hframes[GameData.EnemyType.TANK] = 6

	var tex: Texture2D = enemy_textures.get(enemy_type, null)
	if tex:
		sprite = Sprite2D.new()
		sprite.texture = tex
		sprite.hframes = enemy_hframes.get(enemy_type, 6)
		sprite.frame = 0
		var scale_map: Dictionary = {
			GameData.EnemyType.NORMAL: Vector2(0.4, 0.4),
			GameData.EnemyType.FAST: Vector2(0.35, 0.35),
			GameData.EnemyType.TANK: Vector2(0.5, 0.5),
		}
		sprite.scale = scale_map.get(enemy_type, Vector2(0.4, 0.4))
		add_child(sprite)
		radius = 24.0 if enemy_type != GameData.EnemyType.FAST else 18.0

	if path.size() > 0:
		global_position = game.cell_to_world(path[0])
		path_index = 1

func apply_slow(factor: float, duration: float) -> void:
	slow_factor = 1.0 - factor
	slow_timer = duration

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

	if flash_timer > 0:
		flash_timer -= delta
		if sprite:
			sprite.modulate = Color.WHITE.lerp(Color(1, 0.3, 0.3), flash_timer / FLASH_DURATION)
	elif slow_timer > 0:
		if sprite:
			sprite.modulate = Color(0.6, 0.8, 1.0)  # blue tint when slowed
		else:
			pass  # handled in _draw
	else:
		if sprite:
			sprite.modulate = Color.WHITE

	# Animate sprite frames
	if sprite:
		anim_timer += delta
		if anim_timer >= ANIM_SPEED:
			anim_timer = 0.0
			anim_frame = (anim_frame + 1) % sprite.hframes
			sprite.frame = anim_frame

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
	# Only draw circles for non-sprite enemies (FAST, TANK)
	if sprite:
		# Just draw HP bar
		_draw_hp_bar()
		return

	var draw_color: Color = body_color
	var draw_light: Color = body_color_light

	if flash_timer > 0:
		var flash_mix: float = flash_timer / FLASH_DURATION
		draw_color = draw_color.lerp(Color.WHITE, flash_mix * 0.8)
		draw_light = draw_light.lerp(Color.WHITE, flash_mix * 0.8)

	# Shadow
	draw_circle(Vector2(1.5, 1.5), radius, Color(0, 0, 0, 0.2))
	# Body
	draw_circle(Vector2.ZERO, radius, draw_color)
	# Highlight
	draw_circle(Vector2(-radius * 0.2, -radius * 0.2), radius * 0.5, draw_light)

	# Tank: extra ring
	if enemy_type == GameData.EnemyType.TANK:
		draw_arc(Vector2.ZERO, radius + 2, 0, TAU, 24, body_color.darkened(0.3), 2.0)

	# Fast: speed lines
	if enemy_type == GameData.EnemyType.FAST:
		draw_line(Vector2(-radius - 4, -2), Vector2(-radius - 10, -2), body_color_light, 1.5)
		draw_line(Vector2(-radius - 3, 3), Vector2(-radius - 8, 3), body_color_light, 1.5)

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
