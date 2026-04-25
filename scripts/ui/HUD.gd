extends CanvasLayer

var health_bar: ProgressBar
var health_label: Label

func _ready():
	name = "HUD"
	
	# Container
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 20)
	add_child(margin)
	
	var vbox = VBoxContainer.new()
	margin.add_child(vbox)
	
	# Label
	health_label = Label.new()
	health_label.text = "Player Health: 200/200"
	health_label.add_theme_font_size_override("font_size", 24)
	vbox.add_child(health_label)
	
	# Health Bar
	health_bar = ProgressBar.new()
	health_bar.custom_minimum_size = Vector2(300, 30)
	health_bar.max_value = 200
	health_bar.value = 200
	health_bar.show_percentage = false
	
	# Style
	var sb_bg = StyleBoxFlat.new()
	sb_bg.bg_color = Color(0.2, 0.2, 0.2, 0.8)
	var sb_fg = StyleBoxFlat.new()
	sb_fg.bg_color = Color(0.1, 0.8, 0.2, 1.0)
	health_bar.add_theme_stylebox_override("background", sb_bg)
	health_bar.add_theme_stylebox_override("fill", sb_fg)
	
	vbox.add_child(health_bar)

func update_health(current, maximum):
	if health_bar and health_label:
		health_bar.max_value = maximum
		health_bar.value = current
		health_label.text = "Player Health: %d/%d" % [current, maximum]
