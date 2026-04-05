extends Node2D

var start_pos: Vector2
var end_pos: Vector2 = Vector2(1150, 95)  # where the gold label is
var progress: float = 0.0
var speed: float = 1.2
var coin_value: int = 3

# Bezier curve control point (arc upward)
var control_point: Vector2

func setup(p_start: Vector2, p_value: int) -> void:
	start_pos = p_start
	coin_value = p_value
	global_position = start_pos
	# Control point creates a nice arc
	var mid: Vector2 = (start_pos + end_pos) / 2
	control_point = mid + Vector2(randf_range(-80, 80), -120 - randf_range(0, 80))

func _process(delta: float) -> void:
	progress += delta * speed
	if progress >= 1.0:
		queue_free()
		return

	# Quadratic bezier curve for smooth arc
	var t: float = progress
	var p0: Vector2 = start_pos
	var p1: Vector2 = control_point
	var p2: Vector2 = end_pos
	global_position = (1 - t) * (1 - t) * p0 + 2 * (1 - t) * t * p1 + t * t * p2

	# Scale down as it approaches target
	var s: float = 1.0 - t * 0.5
	scale = Vector2(s, s)

	queue_redraw()

func _draw() -> void:
	var alpha: float = 1.0 - progress * 0.3
	# Gold coin circle
	draw_circle(Vector2.ZERO, 12.0, Color(0.9, 0.7, 0.1, alpha))
	draw_circle(Vector2.ZERO, 8.0, Color(1.0, 0.85, 0.3, alpha))
	# $ symbol
	draw_string(ThemeDB.fallback_font, Vector2(-6, 6), "$", HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color(0.6, 0.4, 0.0, alpha))
