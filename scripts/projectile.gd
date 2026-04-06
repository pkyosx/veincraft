extends Node2D

var from_pos: Vector2
var to_pos: Vector2
var progress: float = 0.0
var done: bool = false
var is_car: bool = false
var car_sprite: Sprite2D = null

static var f1_texture: Texture2D = null

func setup(p_from: Vector2, p_to: Vector2, p_is_car: bool = false) -> void:
	from_pos = p_from
	to_pos = p_to
	global_position = from_pos
	is_car = p_is_car
	if is_car:
		if f1_texture == null:
			f1_texture = load("res://sprites/projectile_f1.png")
		car_sprite = Sprite2D.new()
		car_sprite.texture = f1_texture
		car_sprite.scale = Vector2(2.5, 2.5)
		add_child(car_sprite)
		# Rotate sprite to face direction of travel
		var dir: Vector2 = to_pos - from_pos
		car_sprite.rotation = dir.angle()

func _process(delta: float) -> void:
	if done:
		return
	var spd: float = 3.0 if is_car else 6.0
	progress += delta * spd
	if progress >= 1.0:
		done = true
		return
	global_position = from_pos.lerp(to_pos, progress)
	if not is_car:
		queue_redraw()

func _draw() -> void:
	if not is_car:
		draw_circle(Vector2.ZERO, 3.0, Color(1.0, 0.9, 0.3))
