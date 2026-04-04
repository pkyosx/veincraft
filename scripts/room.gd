extends Node2D

enum RoomType { BASE, OUTPOST, WORMHOLE }

var room_type: int = RoomType.BASE
var room_width: float = 200.0
var room_height: float = 160.0
var room_color: Color = Color(0.25, 0.25, 0.3)
var border_color: Color = Color(0.5, 0.5, 0.6)
var room_name: String = "Room"
var units: Array = []

# Door position (local coordinates, on the edge of the room)
var door_pos_local: Vector2 = Vector2.ZERO
var door_side: String = "right"  # which side the door is on

func setup(p_type: int, p_width: float, p_height: float, p_name: String) -> void:
	room_type = p_type
	room_width = p_width
	room_height = p_height
	room_name = p_name

	if room_type == RoomType.BASE:
		room_color = Color(0.15, 0.2, 0.3)
		border_color = Color(0.3, 0.5, 0.8)
	elif room_type == RoomType.OUTPOST:
		room_color = Color(0.18, 0.18, 0.22)
		border_color = Color(0.45, 0.45, 0.55)
	elif room_type == RoomType.WORMHOLE:
		room_color = Color(0.25, 0.12, 0.18)
		border_color = Color(0.7, 0.2, 0.3)

func set_door(side: String) -> void:
	door_side = side
	match side:
		"right":
			door_pos_local = Vector2(room_width / 2, 0)
		"left":
			door_pos_local = Vector2(-room_width / 2, 0)
		"top":
			door_pos_local = Vector2(0, -room_height / 2)
		"bottom":
			door_pos_local = Vector2(0, room_height / 2)

func get_door_world() -> Vector2:
	return global_position + door_pos_local

func get_random_interior_pos() -> Vector2:
	var margin: float = 25.0
	var rx: float = randf_range(-room_width / 2 + margin, room_width / 2 - margin)
	var ry: float = randf_range(-room_height / 2 + margin, room_height / 2 - margin)
	return global_position + Vector2(rx, ry)

func get_center() -> Vector2:
	return global_position

func add_unit(unit: Node2D) -> void:
	units.append(unit)
	unit.died.connect(_on_unit_died)

func remove_unit(unit: Node2D) -> void:
	units.erase(unit)

func _on_unit_died(unit: Node2D) -> void:
	units.erase(unit)

func get_living_units(team: int) -> Array:
	var result: Array = []
	for u in units:
		if is_instance_valid(u) and not u.is_dead and u.team == team:
			result.append(u)
	return result

func get_rect() -> Rect2:
	return Rect2(global_position - Vector2(room_width / 2, room_height / 2), Vector2(room_width, room_height))

func is_inside(world_pos: Vector2) -> bool:
	return get_rect().has_point(world_pos)

func _draw() -> void:
	var half_w: float = room_width / 2
	var half_h: float = room_height / 2

	# Floor
	draw_rect(Rect2(-half_w, -half_h, room_width, room_height), room_color)

	# Floor pattern (subtle grid)
	var tile_size: float = 32.0
	var line_color: Color = room_color.lightened(0.06)
	var x: float = -half_w
	while x <= half_w:
		draw_line(Vector2(x, -half_h), Vector2(x, half_h), line_color, 1.0)
		x += tile_size
	var y: float = -half_h
	while y <= half_h:
		draw_line(Vector2(-half_w, y), Vector2(half_w, y), line_color, 1.0)
		y += tile_size

	# Walls (thick border)
	draw_rect(Rect2(-half_w, -half_h, room_width, room_height), border_color, false, 3.0)

	# Door opening
	var door_w: float = 30.0
	match door_side:
		"right":
			draw_rect(Rect2(half_w - 2, -door_w / 2, 4, door_w), room_color)
		"left":
			draw_rect(Rect2(-half_w - 2, -door_w / 2, 4, door_w), room_color)
		"top":
			draw_rect(Rect2(-door_w / 2, -half_h - 2, door_w, 4), room_color)
		"bottom":
			draw_rect(Rect2(-door_w / 2, half_h - 2, door_w, 4), room_color)

	# Room name
	draw_string(ThemeDB.fallback_font, Vector2(-half_w + 8, -half_h + 18), room_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, border_color)

	# Wormhole effect
	if room_type == RoomType.WORMHOLE:
		var t: float = fmod(Time.get_ticks_msec() / 1000.0, TAU)
		for i in range(3):
			var r: float = 15.0 + i * 10.0
			var alpha: float = 0.3 - i * 0.08
			draw_arc(Vector2.ZERO, r, t + i * 0.5, t + i * 0.5 + 4.0, 24, Color(0.8, 0.1, 0.3, alpha), 2.0)
		queue_redraw()  # Keep animating
