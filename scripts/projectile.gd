extends Node2D

var from_pos: Vector2
var to_pos: Vector2
var progress: float = 0.0
var done: bool = false

func setup(p_from: Vector2, p_to: Vector2) -> void:
	from_pos = p_from
	to_pos = p_to
	global_position = from_pos

func _process(delta: float) -> void:
	if done:
		return
	progress += delta * 6.0
	if progress >= 1.0:
		done = true
		return
	global_position = from_pos.lerp(to_pos, progress)
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 3.0, Color(1.0, 0.9, 0.3))
