extends Control

@onready var video_player = $VideoStreamPlayer

func _ready():
	# If a video is assigned, play it!
	if video_player.stream != null:
		video_player.play()
	else:
		# If no video is assigned yet, skip straight to the main menu
		_go_to_main_menu()

func _input(event):
	# Allow skipping with any mouse click or key press
	if event is InputEventKey or event is InputEventMouseButton:
		if event.is_pressed():
			_go_to_main_menu()

func _on_video_stream_player_finished():
	_go_to_main_menu()

func _go_to_main_menu():
	get_tree().change_scene_to_file("res://main_menu.tscn")
