extends Control

var hp_label: Label
var gold_label: Label
var wave_label: Label
var phase_label: Label
var bag_container: HBoxContainer
var btn_spin: Button
var btn_premium_spin: Button
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

var btn_speed: Button
var speed_options: Array = [1, 2, 4, 8]
var speed_index: int = 0

# Item icon textures
var item_icons: Dictionary = {}

var game: Node2D

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	game = get_node("/root/Main")
	# Build item list for spin display
	for key in GameData.ITEM_CONFIGS:
		spin_items.append(key)
	_load_item_icons()
	_build_ui()

func _load_item_icons() -> void:
	# Tower icons from tower_sheet.png (4 frames, 64x64 each)
	var sheet: Texture2D = load("res://sprites/tower_sheet.png")
	var tower_items: Array = [GameData.ItemType.TURRET, GameData.ItemType.TREBUCHET, GameData.ItemType.FROST, GameData.ItemType.TESLA]
	for i in range(tower_items.size()):
		var atlas: AtlasTexture = AtlasTexture.new()
		atlas.atlas = sheet
		atlas.region = Rect2(i * 64, 0, 64, 64)
		item_icons[tower_items[i]] = atlas
	# Upgrade and bomb icons
	item_icons[GameData.ItemType.UPGRADE_DMG] = load("res://sprites/icon_dmg.png")
	item_icons[GameData.ItemType.UPGRADE_SPEED] = load("res://sprites/icon_spd.png")
	item_icons[GameData.ItemType.UPGRADE_RANGE] = load("res://sprites/icon_rng.png")
	item_icons[GameData.ItemType.BOMB] = load("res://sprites/icon_bomb.png")
	item_icons[GameData.ItemType.RACER] = load("res://sprites/icon_racer.png")
	item_icons[GameData.ItemType.MEGA_BOMB] = load("res://sprites/icon_mega_bomb.png")
	item_icons[GameData.ItemType.UPGRADE_MEGA_DMG] = load("res://sprites/icon_mega_dmg.png")

func _build_ui() -> void:
	# Right panel background
	var panel_bg: ColorRect = ColorRect.new()
	panel_bg.color = Color(0.1, 0.1, 0.12, 0.9)
	panel_bg.position = Vector2(1160, 0)
	panel_bg.size = Vector2(440, 900)
	panel_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel_bg)

	# Info section
	var info: VBoxContainer = VBoxContainer.new()
	info.position = Vector2(1180, 20)
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
	bag_title.position = Vector2(1180, 220)
	add_child(bag_title)

	bag_container = GridContainer.new()
	bag_container.columns = 4
	bag_container.position = Vector2(1180, 250)
	add_child(bag_container)

	for i in range(GameData.MAX_BAG):
		var btn: Button = Button.new()
		btn.custom_minimum_size = Vector2(80, 80)
		btn.text = ""
		btn.pressed.connect(func() -> void: game.select_bag_item(i))
		# Icon inside button
		var icon: TextureRect = TextureRect.new()
		icon.name = "Icon"
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size = Vector2(64, 64)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(icon)
		bag_container.add_child(btn)

	# Spin display (shows cycling items during animation)
	spin_display = Label.new()
	spin_display.text = "~ SHOP ~"
	spin_display.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	spin_display.add_theme_font_size_override("font_size", 26)
	spin_display.add_theme_color_override("font_color", Color(0.6, 0.6, 0.65))
	spin_display.position = Vector2(1180, 440)
	spin_display.custom_minimum_size = Vector2(340, 45)
	add_child(spin_display)

	# Shop button
	btn_spin = Button.new()
	btn_spin.text = "Spin! ($" + str(GameData.SPIN_COST) + ")"
	btn_spin.custom_minimum_size = Vector2(340, 50)
	btn_spin.position = Vector2(1180, 495)
	btn_spin.add_theme_font_size_override("font_size", 20)
	btn_spin.pressed.connect(_on_spin_pressed)
	add_child(btn_spin)

	# Premium spin button
	btn_premium_spin = Button.new()
	btn_premium_spin.text = "Premium Spin! ($" + str(GameData.PREMIUM_SPIN_COST) + ")"
	btn_premium_spin.custom_minimum_size = Vector2(340, 50)
	btn_premium_spin.position = Vector2(1180, 550)
	btn_premium_spin.add_theme_font_size_override("font_size", 20)
	btn_premium_spin.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	btn_premium_spin.pressed.connect(_on_premium_spin_pressed)
	add_child(btn_premium_spin)

	# Tower shop — direct buy
	var shop_title: Label = Label.new()
	shop_title.text = "Buy Tower"
	shop_title.add_theme_font_size_override("font_size", 18)
	shop_title.position = Vector2(1180, 615)
	add_child(shop_title)

	var tower_grid: GridContainer = GridContainer.new()
	tower_grid.columns = 2
	tower_grid.position = Vector2(1180, 645)
	tower_grid.name = "TowerGrid"
	add_child(tower_grid)

	for tower_type in GameData.TOWER_CONFIGS:
		var tc: Dictionary = GameData.TOWER_CONFIGS[tower_type]
		var btn: Button = Button.new()
		btn.custom_minimum_size = Vector2(165, 45)
		btn.text = tc["name"] + " $" + str(tc["cost"])
		var captured_type: int = tower_type
		btn.pressed.connect(func() -> void: _buy_tower(captured_type))
		tower_grid.add_child(btn)

	# Play button
	btn_play = Button.new()
	btn_play.text = "▶ Play"
	btn_play.custom_minimum_size = Vector2(340, 55)
	btn_play.position = Vector2(1180, 755)
	btn_play.add_theme_font_size_override("font_size", 24)
	btn_play.pressed.connect(func() -> void: game.start_wave())
	add_child(btn_play)

	# Speed button
	btn_speed = Button.new()
	btn_speed.text = "Speed: 1x"
	btn_speed.custom_minimum_size = Vector2(340, 45)
	btn_speed.position = Vector2(1180, 815)
	btn_speed.add_theme_font_size_override("font_size", 20)
	btn_speed.pressed.connect(_on_speed_pressed)
	add_child(btn_speed)

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

var is_premium_spin: bool = false

func _on_premium_spin_pressed() -> void:
	if spin_active:
		return
	if game.gold < GameData.PREMIUM_SPIN_COST or game.bag.size() >= GameData.MAX_BAG:
		return
	game.gold -= GameData.PREMIUM_SPIN_COST
	spin_result = GameData.roll_shop_item(true)
	is_premium_spin = true
	spin_active = true
	spin_timer = 0.0
	spin_tick = 0.0
	spin_interval = 0.05
	spin_current_display = 0
	btn_spin.disabled = true
	btn_premium_spin.disabled = true
	get_node("/root/Audio").play_spin()
	game._update_hud()

func _on_speed_pressed() -> void:
	speed_index = (speed_index + 1) % speed_options.size()
	var spd: int = speed_options[speed_index]
	Engine.time_scale = spd
	btn_speed.text = "Speed: " + str(spd) + "x"

func _buy_tower(tower_type: int) -> void:
	var tc: Dictionary = GameData.TOWER_CONFIGS[tower_type]
	var cost: int = tc["cost"]
	if game.gold < cost:
		return
	if game.bag.size() >= GameData.MAX_BAG:
		return
	if game.phase != "build":
		return
	game.gold -= cost
	game.bag.append(tc["item"])
	get_node("/root/Audio").play_sfx("place")
	game._update_hud()

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
	get_node("/root/Audio").play_spin()
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
		# Landing — stop spin sound, play jackpot
		spin_active = false
		get_node("/root/Audio").stop_spin()
		var config: Dictionary = GameData.ITEM_CONFIGS[spin_result]
		spin_display.text = "★ " + config["name"] + " ★"
		spin_display.add_theme_color_override("font_color", config["color"].lightened(0.3))
		get_node("/root/Audio").play_sfx("jackpot", 0.0)
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
		var icon: TextureRect = btn.get_node("Icon")
		if i < p_bag.size():
			var item_type: int = p_bag[i]
			var config: Dictionary = GameData.ITEM_CONFIGS[item_type]
			btn.text = ""
			btn.tooltip_text = config["name"]
			btn.disabled = false
			icon.texture = item_icons.get(item_type, null)
			icon.visible = true
			if i == p_selected:
				btn.modulate = Color(1, 1, 0.5)
			else:
				btn.modulate = Color.WHITE
		else:
			btn.text = ""
			btn.tooltip_text = ""
			btn.disabled = true
			btn.modulate = Color.WHITE
			icon.texture = null
			icon.visible = false

	# Tower buy buttons
	var tower_grid: GridContainer = get_node("TowerGrid")
	var idx: int = 0
	for tower_type in GameData.TOWER_CONFIGS:
		if idx < tower_grid.get_child_count():
			var btn: Button = tower_grid.get_child(idx)
			var tc: Dictionary = GameData.TOWER_CONFIGS[tower_type]
			btn.disabled = p_gold < tc["cost"] or p_bag.size() >= GameData.MAX_BAG or p_phase != "build"
		idx += 1

	# Button states
	var can_spin: bool = p_bag.size() < GameData.MAX_BAG and p_phase == "build" and not spin_active
	btn_spin.disabled = not (can_spin and p_gold >= GameData.SPIN_COST)
	btn_premium_spin.disabled = not (can_spin and p_gold >= GameData.PREMIUM_SPIN_COST)
	btn_play.disabled = p_phase != "build" or spin_active
	btn_play.visible = not p_game_over
	btn_spin.visible = not p_game_over
	btn_premium_spin.visible = not p_game_over

	if p_game_over:
		end_panel.visible = true
		var wave_word = "wave" if p_wave == 1 else "waves"
		end_text.text = "Game Over!\nSurvived " + str(p_wave) + " " + wave_word
		end_text.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2))
