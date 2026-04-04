extends Control

var protector_label: Label
var resource_label: Label
var resource_bar: ProgressBar
var wormhole_label: Label
var wormhole_bar: ProgressBar
var wh_row: HBoxContainer
var status_label: Label
var end_panel: PanelContainer
var end_text: Label
var restart_btn: Button

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_ui()

func _build_ui() -> void:
	var top: VBoxContainer = VBoxContainer.new()
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.position = Vector2(20, 10)
	add_child(top)

	protector_label = Label.new()
	protector_label.text = "Protectors: 4"
	protector_label.add_theme_font_size_override("font_size", 20)
	protector_label.add_theme_color_override("font_color", Color(0.3, 0.7, 1.0))
	top.add_child(protector_label)

	var res_row: HBoxContainer = HBoxContainer.new()
	res_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(res_row)

	var res_lbl: Label = Label.new()
	res_lbl.text = "Base: "
	res_lbl.add_theme_font_size_override("font_size", 18)
	res_row.add_child(res_lbl)

	resource_bar = ProgressBar.new()
	resource_bar.custom_minimum_size = Vector2(200, 18)
	resource_bar.max_value = 100
	resource_bar.value = 100
	resource_bar.show_percentage = false
	res_row.add_child(resource_bar)

	resource_label = Label.new()
	resource_label.text = " 100 / 100"
	resource_label.add_theme_font_size_override("font_size", 16)
	res_row.add_child(resource_label)

	wh_row = HBoxContainer.new()
	wh_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wh_row.visible = false
	top.add_child(wh_row)

	wormhole_label = Label.new()
	wormhole_label.text = "Wormhole: "
	wormhole_label.add_theme_font_size_override("font_size", 18)
	wormhole_label.add_theme_color_override("font_color", Color(0.8, 0.3, 0.3))
	wh_row.add_child(wormhole_label)

	wormhole_bar = ProgressBar.new()
	wormhole_bar.custom_minimum_size = Vector2(200, 18)
	wormhole_bar.max_value = 80
	wormhole_bar.value = 80
	wormhole_bar.show_percentage = false
	wh_row.add_child(wormhole_bar)

	status_label = Label.new()
	status_label.text = "Peaceful..."
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.add_theme_color_override("font_color", Color(0.6, 0.8, 0.6))
	top.add_child(status_label)

	end_panel = PanelContainer.new()
	end_panel.visible = false
	end_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(end_panel)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	end_panel.add_child(vbox)

	end_text = Label.new()
	end_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	end_text.add_theme_font_size_override("font_size", 26)
	vbox.add_child(end_text)

	restart_btn = Button.new()
	restart_btn.text = "Play Again"
	restart_btn.custom_minimum_size = Vector2(160, 40)
	restart_btn.pressed.connect(_on_restart)
	vbox.add_child(restart_btn)

	end_panel.set_anchors_preset(Control.PRESET_CENTER)
	end_panel.custom_minimum_size = Vector2(400, 140)

func update_info(protectors_alive: int, resources: int, max_res: int, wh_hp: int, wh_max_hp: int, wh_active: bool) -> void:
	protector_label.text = "Protectors: " + str(protectors_alive)
	resource_label.text = " " + str(resources) + " / " + str(max_res)
	resource_bar.max_value = max_res
	resource_bar.value = resources

	wh_row.visible = wh_active
	if wh_active:
		wormhole_bar.max_value = wh_max_hp
		wormhole_bar.value = wh_hp
		wormhole_label.text = "Wormhole: " + str(wh_hp) + "/" + str(wh_max_hp) + " "

	if not wh_active:
		status_label.text = "Peaceful... something stirs"
		status_label.add_theme_color_override("font_color", Color(0.6, 0.8, 0.6))
	else:
		status_label.text = "Wormhole active! Destroy it!"
		status_label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))

func show_victory(enemies_killed: int, resources_left: int) -> void:
	end_panel.visible = true
	end_text.text = "Victory!\nWormhole Destroyed!\nEnemies defeated: " + str(enemies_killed) + "\nResources remaining: " + str(resources_left)
	end_text.add_theme_color_override("font_color", Color(0.3, 0.9, 0.3))

func show_defeat(enemies_spawned: int) -> void:
	end_panel.visible = true
	end_text.text = "Base Overrun!\nResources depleted!\nEnemies spawned: " + str(enemies_spawned)
	end_text.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2))

func _on_restart() -> void:
	end_panel.visible = false
	var main: Node2D = get_node("/root/Main")
	if main and main.has_method("restart"):
		main.restart()
