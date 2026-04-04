extends Node2D

var point_a: Vector2 = Vector2.ZERO
var point_b: Vector2 = Vector2.ZERO
var width: float = 30.0
var color: Color = Color(0.2, 0.2, 0.25)
var border_color: Color = Color(0.4, 0.4, 0.45)

func setup(a: Vector2, b: Vector2) -> void:
	point_a = a
	point_b = b

func _draw() -> void:
	# Draw corridor as thick line with borders
	var a: Vector2 = to_local(point_a)
	var b: Vector2 = to_local(point_b)

	# Background
	draw_line(a, b, color, width)
	# Borders
	var dir: Vector2 = (b - a).normalized()
	var perp: Vector2 = Vector2(-dir.y, dir.x) * width / 2
	draw_line(a + perp, b + perp, border_color, 2.0)
	draw_line(a - perp, b - perp, border_color, 2.0)
