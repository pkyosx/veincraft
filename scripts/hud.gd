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

# Spin animation
var spin_display: Label
var spin_active: bool = false
var spin_timer: float = 0.0
var spin_duration: float = 1.5
var spin_tick: float = 0.0
var spin_interval: float = 0.05  # starts fast
var spin_result: int = -1
var spin_current_display: int = 0
var spin_items: Array = []  # all possible items to cycle through

var game: Node2D

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	game = get_node("/root/Main")
	# Build item list for spin display
	for key in GameData.ITEM_CONFIGS:
		spin_items.append(key)
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

	for i in range(GameData.MAX_BAG):
		var btn: Button = Button.new()
		btn.custom_minimum_size = Vector2(80, 80)
		btn.text = ""
		btn.pressed.connect(func() -> void: game.select_bag_item(i))
		bag_container.add_child(btn)

	# Spin display (shows cycling items during animation)
	spin_display = Label.new()
	spin_display.text = "~ SHOP ~"
	spin_display.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	spin_display.add_theme_font_size_override("font_size", 26)
	spin_display.add_theme_color_override("font_color", Color(0.6, 0.6, 0.65))
	spin_display.position = Vector2(920, 345)
	spin_display.custom_minimum_size = Vector2(340, 45)
	add_child(spin_display)

	# Shop button
	btn_spin = Button.new()
	btn_spin.text = "Spin! ($" + str(GameData.SPIN_COST) + ")"
	btn_spin.custom_minimum_size = Vector2(340, 50)
	btn_spin.position = Vector2(920, 395)
	btn_spin.add_theme_font_size_override("font_size", 20)
	btn_spin.pressed.connect(_on_spin_pressed)
	add_child(btn_spin)

	# Play button
	btn_play = Button.new()
	btn_play.text = "▶ Play"
	btn_play.custom_minimum_size = Vector2(340, 55)
	btn_play.position = Vector2(920, 460)
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

func _on_spin_pressed() -> void:
	if spin_active:
		return
	if game.gold < GameData.SPIN_COST or game.bag.size() >= GameData.MAX_BAG:
		return
	# Deduct gold immediately
	game.gold -= GameData.SPIN_COST
	# Roll the result now but reveal later
	spin_result = GameData.roll_shop_item()
	spin_active = true
	spin_timer = 0.0
	spin_tick = 0.0
	spin_interval = 0.05
	spin_current_display = 0
	btn_spin.disabled = true
	game._update_hud()

func _process(delta: float) -> void:
	if not spin_active:
		return

	spin_timer += delta
	spin_tick += delta

	# Speed curve: fast at start, slow down toward end
	var progress: float = spin_timer / spin_duration
	spin_interval = 0.05 + progress * progress * 0.3  # accelerating slowdown

	if spin_tick >= spin_interval:
		spin_tick = 0.0
		# Cycle to next item
		spin_current_display = (spin_current_display + 1) % spin_items.size()
		var item: int = spin_items[spin_current_display]
		var config: Dictionary = GameData.ITEM_CONFIGS[item]
		spin_display.text = ">> " + config["name"] + " <<"
		spin_display.add_theme_color_override("font_color", config["color"])

	if spin_timer >= spin_duration:
		# Landing — show final result
		spin_active = false
		var config: Dictionary = GameData.ITEM_CONFIGS[spin_result]
		spin_display.text = "★ " + config["name"] + " ★"
		spin_display.add_theme_color_override("font_color", config["color"].lightened(0.3))
		# Add to bag
		game.bag.append(spin_result)
		game._update_hud()
		# Reset display after a moment
		_reset_spin_display_delayed()

func _reset_spin_display_delayed() -> void:
	await get_tree().create_timer(1.0).timeout
	if not spin_active:
		spin_display.text = "~ SHOP ~"
		spin_display.add_theme_color_override("font_color", Color(0.6, 0.6, 0.65))

func refresh(p_hp: int, p_gold: int, p_wave: int, p_max_waves: int, p_bag: Array, p_selected: int, p_phase: String, p_game_over: bool) -> void:
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
	var can_spin: bool = p_gold >= GameData.SPIN_COST and p_bag.size() < GameData.MAX_BAG and p_phase == "build" and not spin_active
	btn_spin.disabled = not can_spin
	btn_play.disabled = p_phase != "build" or spin_active
	btn_play.visible = not p_game_over
	btn_spin.visible = not p_game_over

	if p_game_over:
		end_panel.visible = true
		end_text.text = "Game Over!\nSurvived " + str(p_wave) + " waves"
		end_text.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2))
