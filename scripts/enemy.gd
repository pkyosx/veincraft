extends Node2D

var path: Array = []
var path_index: int = 0
var path_progress: float = 0.0  # total distance traveled (for tower targeting priority)
var hp: int = 10
var max_hp: int = 10
var speed: float = 60.0
var is_dead: bool = false
var reached_end: bool = false
var game: Node2D

const RADIUS: float = 10.0

func setup(p_path: Array, p_hp: int, p_speed: float, p_game: Node2D) -> void:
	path = p_path
	hp = p_hp
	max_hp = p_hp
	speed = p_speed
	game = p_game
	if path.size() > 0:
		global_position = game.cell_to_world(path[0])
		path_index = 1

func _process(delta: float) -> void:
	if is_dead or reached_end:
		return
	if path_index >= path.size():
		reached_end = true
		return

	var target: Vector2 = game.cell_to_world(path[path_index])
	var dir: Vector2 = target - global_position
	var move: float = speed * delta

	if dir.length() <= move:
		global_position = target
		path_index += 1
		path_progress += 1.0
	else:
		global_position += dir.normalized() * move
		path_progress += move / GameData.CELL_SIZE

	queue_redraw()

func take_damage(amount: int) -> void:
	if is_dead:
		return
	hp -= amount
	if hp <= 0:
		hp = 0
		is_dead = true

func _draw() -> void:
	# Shadow
	draw_circle(Vector2(1.5, 1.5), RADIUS, Color(0, 0, 0, 0.2))
	# Body
	draw_circle(Vector2.ZERO, RADIUS, Color(0.3, 0.7, 0.15))
	draw_circle(Vector2(-2, -2), RADIUS * 0.5, Color(0.4, 0.85, 0.25))
	# HP bar
	if hp < max_hp:
		var w: float = 22.0
		var h: float = 3.0
		var bar_y: float = -RADIUS - 6
		draw_rect(Rect2(-w/2, bar_y, w, h), Color(0.15, 0.15, 0.15))
		var ratio: float = float(hp) / float(max_hp)
		draw_rect(Rect2(-w/2, bar_y, w * ratio, h), Color(0.9, 0.2, 0.2) if ratio < 0.3 else Color(0.2, 0.8, 0.2))
