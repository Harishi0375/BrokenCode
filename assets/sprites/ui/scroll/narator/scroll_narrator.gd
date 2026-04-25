extends Control

var messages = []
var current_index = 0
var char_index = 0
var typing_speed = 0.05
var wait_between = 3.0

func start_sequence(new_messages: Array):
    messages = new_messages
    current_index = 0
    visible = true
    _show_current_message()

func _show_current_message():
    if current_index >= messages.size():
        hide_scroll()
        return
    $TextureRect/Label.text = ""
    char_index = 0
    _type_next_character()

func _type_next_character():
    var current_msg = messages[current_index]
    if char_index < current_msg.length():
        $TextureRect/Label.text += current_msg[char_index]
        char_index += 1
        await get_tree().create_timer(typing_speed).timeout
        _type_next_character()
    else:
        await get_tree().create_timer(wait_between).timeout
        current_index += 1
        _show_current_message()

func hide_scroll():
    visible = false