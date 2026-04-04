extends Control

var hp_label: Label
var gold_label: Label
var wave_label: Label
var phase_label: Label
var bag_container: HBoxContainer
var btn_spin: Button
var btn_play: Button
var btn_restart: Button
var end_panel: PanelContainer
var end_text: Label

var game: Node2D

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	game = get_node("/root/Main")
	_build_ui()

func _build_ui() -> void:
	# Right panel background
	var panel_bg: ColorRect = ColorRect.new()
	panel_bg.color = Color(0.1, 0.1, 0.12, 0.9)
	panel_bg.position = Vector2(910, 0)
	panel_bg.size = Vector2(370, 720)
	panel_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel_bg)

	# Info section
	var info: VBoxContainer = VBoxContainer.new()
	info.position = Vector2(920, 20)
	info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(info)

	var title: Label = Label.new()
	title.text = "Info"
	title.add_theme_font_size_override("font_size", 22)
	info.add_child(title)

	hp_label = Label.new()
	hp_label.add_theme_font_size_override("font_size", 20)
	hp_label.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2))
	info.add_child(hp_label)

	gold_label = Label.new()
	gold_label.add_theme_font_size_override("font_size", 22)
	gold_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.1))
	info.add_child(gold_label)

	wave_label = Label.new()
	wave_label.add_theme_font_size_override("font_size", 18)
	info.add_child(wave_label)

	phase_label = Label.new()
	phase_label.add_theme_font_size_override("font_size", 16)
	info.add_child(phase_label)

	# Bag section
	var bag_title: Label = Label.new()
	bag_title.text = "Bag (0/4)"
	bag_title.name = "BagTitle"
	bag_title.add_theme_font_size_override("font_size", 18)
	bag_title.position = Vector2(920, 220)
	add_child(bag_title)

	bag_container = HBoxContainer.new()
	bag_container.position = Vector2(920, 250)
	add_child(bag_container)

	# Create 4 bag slot buttons
	for i in range(GameData.MAX_BAG):
		var btn: Button = Button.new()
		btn.custom_minimum_size = Vector2(80, 80)
		btn.text = ""
		btn.pressed.connect(func() -> void: game.select_bag_item(i))
		bag_container.add_child(btn)

	# Shop button
	btn_spin = Button.new()
	btn_spin.text = "Spin! ($" + str(GameData.SPIN_COST) + ")"
	btn_spin.custom_minimum_size = Vector2(340, 50)
	btn_spin.position = Vector2(920, 350)
	btn_spin.add_theme_font_size_override("font_size", 20)
	btn_spin.pressed.connect(func() -> void: game.buy_spin())
	add_child(btn_spin)

	# Play button
	btn_play = Button.new()
	btn_play.text = "Play"
	btn_play.custom_minimum_size = Vector2(340, 55)
	btn_play.position = Vector2(920, 420)
	btn_play.add_theme_font_size_override("font_size", 24)
	btn_play.pressed.connect(func() -> void: game.start_wave())
	add_child(btn_play)

	# End panel (hidden)
	end_panel = PanelContainer.new()
	end_panel.visible = false
	end_panel.set_anchors_preset(Control.PRESET_CENTER)
	end_panel.custom_minimum_size = Vector2(400, 160)
	add_child(end_panel)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	end_panel.add_child(vbox)

	end_text = Label.new()
	end_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	end_text.add_theme_font_size_override("font_size", 26)
	vbox.add_child(end_text)

	btn_restart = Button.new()
	btn_restart.text = "Play Again"
	btn_restart.custom_minimum_size = Vector2(160, 40)
	btn_restart.pressed.connect(func() -> void:
		end_panel.visible = false
		game.restart()
	)
	vbox.add_child(btn_restart)

func refresh(p_hp: int, p_gold: int, p_wave: int, p_max_waves: int, p_bag: Array, p_selected: int, p_phase: String, p_game_over: bool) -> void:
	# HP as hearts
	var hearts: String = ""
	for i in range(GameData.MAX_HP):
		hearts += "♥ " if i < p_hp else "♡ "
	hp_label.text = hearts

	gold_label.text = "$" + str(p_gold)
	wave_label.text = "Wave: " + str(p_wave) + " / " + str(p_max_waves)

	match p_phase:
		"build":
			phase_label.text = "BUILD"
			phase_label.add_theme_color_override("font_color", Color(0.3, 0.9, 0.3))
		"fight":
			phase_label.text = "FIGHT!"
			phase_label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
		_:
			phase_label.text = ""

	# Bag
	var bag_title_node: Label = get_node("BagTitle")
	bag_title_node.text = "Bag (" + str(p_bag.size()) + "/" + str(GameData.MAX_BAG) + ")"

	for i in range(GameData.MAX_BAG):
		var btn: Button = bag_container.get_child(i)
		if i < p_bag.size():
			var config: Dictionary = GameData.ITEM_CONFIGS[p_bag[i]]
			btn.text = config["name"]
			btn.disabled = false
			if i == p_selected:
				btn.add_theme_color_override("font_color", Color(1, 1, 0))
			else:
				btn.remove_theme_color_override("font_color")
		else:
			btn.text = ""
			btn.disabled = true
			btn.remove_theme_color_override("font_color")

	# Button states
	btn_spin.disabled = p_gold < GameData.SPIN_COST or p_bag.size() >= GameData.MAX_BAG or p_phase != "build"
	btn_play.disabled = p_phase != "build"
	btn_play.visible = not p_game_over
	btn_spin.visible = not p_game_over

	# Game over
	if p_game_over:
		end_panel.visible = true
		end_text.text = "Game Over!\nSurvived " + str(p_wave) + " waves"
		end_text.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2))
