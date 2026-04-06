extends Node2D

var from_pos: Vector2
var to_pos: Vector2
var progress: float = 0.0
var done: bool = false
var car_type: String = ""  # "", "f1", "police"
var car_sprite: Sprite2D = null

static var f1_texture: Texture2D = null
static var police_texture: Texture2D = null

func setup(p_from: Vector2, p_to: Vector2, p_car_type: String = "") -> void:
	from_pos = p_from
	to_pos = p_to
	global_position = from_pos
	car_type = p_car_type
	if car_type != "":
		var tex: Texture2D
		if car_type == "police":
			if police_texture == null:
				police_texture = load("res://sprites/projectile_police.png")
			tex = police_texture
		else:
			if f1_texture == null:
				f1_texture = load("res://sprites/projectile_f1.png")
			tex = f1_texture
		car_sprite = Sprite2D.new()
		car_sprite.texture = tex
		car_sprite.scale = Vector2(1.8, 1.8)
		add_child(car_sprite)
		var dir: Vector2 = to_pos - from_pos
		car_sprite.rotation = dir.angle()

func _process(delta: float) -> void:
	if done:
		return
	var spd: float = 3.0 if car_type != "" else 6.0
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
