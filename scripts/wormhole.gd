extends Node2D

var flash_timer: float = 0.0

func _process(_delta: float) -> void:
	if flash_timer > 0:
		flash_timer -= _delta
	queue_redraw()

func flash() -> void:
	flash_timer = 0.15

func _draw() -> void:
	var t: float = Time.get_ticks_msec() / 1000.0

	# Outer glow
	for i in range(4):
		var r: float = 30.0 + i * 8.0
		var alpha: float = 0.2 - i * 0.04
		draw_arc(Vector2.ZERO, r, 0, TAU, 48, Color(0.7, 0.1, 0.2, alpha), 3.0)

	# Swirling rings
	for i in range(3):
		var r: float = 12.0 + i * 8.0
		var start: float = fmod(t * (1.5 + i * 0.3), TAU)
		var alpha: float = 0.6 - i * 0.15
		draw_arc(Vector2.ZERO, r, start, start + 4.5, 24, Color(0.9, 0.15, 0.3, alpha), 2.5)

	# Center
	var pulse: float = 0.8 + sin(t * 3.0) * 0.2
	draw_circle(Vector2.ZERO, 8.0 * pulse, Color(0.4, 0.0, 0.1))
	draw_circle(Vector2.ZERO, 5.0 * pulse, Color(0.8, 0.1, 0.2))

	# Flash white when hit
	if flash_timer > 0:
		draw_circle(Vector2.ZERO, 25.0, Color(1.0, 1.0, 1.0, flash_timer * 4.0))
