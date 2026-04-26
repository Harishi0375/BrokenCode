extends Control

# All narration lines. [P] = show player icon. [N] = narrator, no icon.
const NARRATION_LINES: Array[String] = [
	"[N]You built this. You broke this. The only exit is the end screen.",
	"[N]To escape, you must do the one thing you never managed from the outside. Finish all three games.",
	"[P]What where okay. OKAY. I am inside my game. I am literally inside my own game. Getting stuck here wasn't enough, now I'm hearing voices too?!",
	"[N]Not voices. Singular. Just one voice.",
	"[P]WHO IS THAT.",
	"[N]No one important. Just the voice your games never had since you clearly weren't going to add proper dialogue yourself.",
	"[P]Okay. Okay okay okay. My games were full of bugs. How am I even supposed to survive this?",
	"[P]...Actually. I BUILT these games. So I know every bug, every shortcut, every broken corner. Maybe I can use that.",
	"[P]Maybe."
]

const CHARS_PER_SECOND: float = 45.0

@onready var label: Label      = $CenterContainer/HBox/Label
@onready var icon: TextureRect = $CenterContainer/HBox/Icon
@onready var prompt: Label     = $PromptLabel
@onready var bg: ColorRect     = $Background

var _line_index: int    = 0
var _full_text: String  = ""
var _char_pos: float    = 0.0
var _typing: bool       = false
var _transitioning: bool = false

# Ignore input for the first few frames so a held key from a previous scene
# doesn't immediately skip the first line.
var _input_cooldown: float = 0.4

func _ready() -> void:
	label.text = ""
	prompt.visible = false
	icon.visible = false
	_show_line(0)

func _show_line(idx: int) -> void:
	var raw: String = NARRATION_LINES[idx]

	if raw.begins_with("[P]"):
		_full_text = raw.substr(3)
		icon.visible = true
	elif raw.begins_with("[N]"):
		_full_text = raw.substr(3)
		icon.visible = false
	else:
		_full_text = raw
		icon.visible = false

	label.text = ""
	_char_pos   = 0.0
	_typing     = true
	prompt.visible = false

func _process(delta: float) -> void:
	if _transitioning:
		return

	# Cool-down timer to avoid eating the first input
	if _input_cooldown > 0.0:
		_input_cooldown -= delta
		return

	if _typing:
		_char_pos += CHARS_PER_SECOND * delta
		var shown := mini(int(_char_pos), _full_text.length())
		label.text = _full_text.substr(0, shown)
		if shown >= _full_text.length():
			_finish_typing()

func _finish_typing() -> void:
	label.text = _full_text
	_typing = false
	prompt.visible = true

func _input(event: InputEvent) -> void:
	if _transitioning or _input_cooldown > 0.0:
		return

	var pressed := false
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		pressed = true
	elif event is InputEventMouseButton and event.is_pressed():
		pressed = true

	if not pressed:
		return

	if _typing:
		# ONE press: instantly complete the line AND immediately advance
		_finish_typing()
		get_tree().create_timer(0.05).timeout.connect(_advance)
	else:
		_advance()

func _advance() -> void:
	if _transitioning:
		return
	_line_index += 1
	if _line_index < NARRATION_LINES.size():
		_show_line(_line_index)
	else:
		_go_to_menu()

func _go_to_menu() -> void:
	_transitioning = true
	prompt.visible = false
	var tween = create_tween()
	tween.tween_property(bg, "modulate:a", 0.0, 0.8)
	tween.tween_callback(func():
		get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
	)
