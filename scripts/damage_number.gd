extends Node2D

var text: String = ""
var lifetime: float = 0.6
var timer: float = 0.0
var velocity: Vector2 = Vector2(0, -50)
var font_size: int = 14

func setup(p_text: String, p_pos: Vector2) -> void:
	text = p_text
	global_position = p_pos
	# Bigger numbers = bigger font
	if p_text.to_int() >= 8:
		font_size = 18
	velocity.x = randf_range(-15, 15)

func _process(delta: float) -> void:
	timer += delta
	global_position += velocity * delta
	velocity.y += 80 * delta  # gravity
	if timer >= lifetime:
		queue_free()
	queue_redraw()

func _draw() -> void:
	var alpha: float = 1.0 - (timer / lifetime)
	var color: Color = Color(1.0, 0.85, 0.1, alpha)
	# Outline
	draw_string(ThemeDB.fallback_font, Vector2(-9, 1), text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color(0, 0, 0, alpha * 0.6))
	# Text
	draw_string(ThemeDB.fallback_font, Vector2(-10, 0), text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, color)
