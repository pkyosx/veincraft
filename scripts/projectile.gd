extends Node2D

var from_pos: Vector2
var to_pos: Vector2
var progress: float = 0.0
var done: bool = false
var car_type: String = ""
var car_sprite: Sprite2D = null

static var car_textures: Dictionary = {}

func setup(p_from: Vector2, p_to: Vector2, p_car_type: String = "") -> void:
	from_pos = p_from
	to_pos = p_to
	global_position = from_pos
	car_type = p_car_type
	if car_type != "":
		if not car_textures.has(car_type):
			var path: String = "res://sprites/projectile_" + car_type + ".png"
			car_textures[car_type] = load(path)
		car_sprite = Sprite2D.new()
		car_sprite.texture = car_textures[car_type]
		var s: float = 2.2 if car_type == "monstertruck" else 1.8
		car_sprite.scale = Vector2(s, s)
		add_child(car_sprite)
		var dir: Vector2 = to_pos - from_pos
		car_sprite.rotation = dir.angle()

func _process(delta: float) -> void:
	if done:
		return
	var spd: float = 2.5 if car_type == "monstertruck" else (3.0 if car_type != "" else 6.0)
	progress += delta * spd
	if progress >= 1.0:
		done = true
		return
	global_position = from_pos.lerp(to_pos, progress)
	if car_type == "":
		queue_redraw()

func _draw() -> void:
	if car_type == "":
		draw_circle(Vector2.ZERO, 3.0, Color(1.0, 0.9, 0.3))
