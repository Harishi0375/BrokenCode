extends CanvasLayer

signal dialogue_finished

@onready var label: Label = $Panel/Label
@onready var panel: Control = $Panel
@onready var player_icon: TextureRect = $Panel/PlayerIcon

var dialogue_lines: Array[String] = []
var current_line_index: int = 0
var is_dialogue_active: bool = false

func _ready() -> void:
	# Ensure the UI is hidden on start
	panel.hide()

func _process(_delta: float) -> void:
	if is_dialogue_active and Input.is_action_just_pressed("ui_accept"):
		advance_dialogue()

func show_dialogue(lines: Array[String]) -> void:
	if lines.size() == 0:
		return
	
	dialogue_lines = lines
	current_line_index = 0
	is_dialogue_active = true
	
	display_current_line()
	panel.show()
	get_tree().paused = true # Pause the game while dialogue is showing

func display_current_line() -> void:
	var line = dialogue_lines[current_line_index]
	
	# Check for speaker prefixes
	if line.begins_with("[P]"):
		line = line.substr(3).strip_edges()
		player_icon.show()
		label.offset_left = 220.0
	elif line.begins_with("[N]"):
		line = line.substr(3).strip_edges()
		player_icon.hide()
		label.offset_left = 100.0
	else:
		player_icon.hide()
		label.offset_left = 100.0
		
	# Remove dashes/em-dashes
	line = line.replace("—", "").replace("-", "").strip_edges()
	
	# Strip leading quotes just in case since they were wrapped in quotes
	if line.begins_with('"'):
		line = line.substr(1)
	if line.ends_with('"'):
		line = line.substr(0, line.length() - 1)
		
	label.text = line.strip_edges()

func advance_dialogue() -> void:
	current_line_index += 1
	if current_line_index < dialogue_lines.size():
		display_current_line()
	else:
		finish_dialogue()

func finish_dialogue() -> void:
	is_dialogue_active = false
	panel.hide()
	get_tree().paused = false # Unpause the game
	emit_signal("dialogue_finished")
