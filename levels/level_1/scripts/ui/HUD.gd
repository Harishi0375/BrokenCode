extends CanvasLayer

var hearts_container: HBoxContainer
var death_overlay: ColorRect
var death_label: Label
var retry_button: Button

func _ready():
	name = "HUD"
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 20)
	add_child(margin)
	
	var vbox = VBoxContainer.new()
	margin.add_child(vbox)
	
	hearts_container = HBoxContainer.new()
	vbox.add_child(hearts_container)
	
	setup_death_screen()

func setup_death_screen():
	death_overlay = ColorRect.new()
	death_overlay.color = Color(0, 0, 0, 0)
	death_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	death_overlay.visible = false
	add_child(death_overlay)
	
	var center = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	death_overlay.add_child(center)
	
	var dvbox = VBoxContainer.new()
	center.add_child(dvbox)
	
	death_label = Label.new()
	death_label.text = "YOU ARE DEAD"
	death_label.add_theme_font_size_override("font_size", 48)
	death_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dvbox.add_child(death_label)
	
	retry_button = Button.new()
	retry_button.text = "TRY AGAIN"
	retry_button.custom_minimum_size = Vector2(200, 50)
	retry_button.pressed.connect(_on_retry_pressed)
	dvbox.add_child(retry_button)

func update_health(_current, _maximum):
	pass

func update_lives(count):
	for child in hearts_container.get_children():
		child.queue_free()
	for i in range(count):
		var heart = Label.new()
		heart.text = "❤️ "
		heart.add_theme_font_size_override("font_size", 32)
		hearts_container.add_child(heart)

func show_death_screen(is_game_over):
	death_overlay.visible = true
	death_label.text = "GAME OVER" if is_game_over else "YOU ARE DEAD"
	retry_button.text = "RESTART GAME" if is_game_over else "TRY AGAIN"
	
	var tween = create_tween()
	tween.tween_property(death_overlay, "color", Color(0, 0, 0, 0.8), 1.0)

func show_victory_screen():
	death_overlay.visible = true
	death_label.text = "VICTORY!"
	death_label.modulate = Color(1.0, 0.8, 0.2) # Gold color
	retry_button.text = "PLAY AGAIN"
	
	var tween = create_tween()
	tween.tween_property(death_overlay, "color", Color(0, 0, 0, 1.0), 1.5)

func _on_retry_pressed():
	if death_label.text == "GAME OVER" or death_label.text == "VICTORY!":
		GameManager.restart_game()
	else:
		GameManager.respawn_player()
