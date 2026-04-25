extends Control

@onready var video_player = $VideoStreamPlayer

func _ready():
	# Wait one frame to ensure resources are loaded
	await get_tree().process_frame
	
	if video_player.stream != null:
		print("Intro: Video stream found, playing...")
		video_player.play()
	else:
		# If it's null, wait a bit longer just in case Godot is slow
		print("Intro: Video stream null, waiting 0.5s...")
		await get_tree().create_timer(0.5).timeout
		if video_player.stream != null:
			video_player.play()
		else:
			print("Intro: Video stream STILL null, skipping to menu.")
			_go_to_main_menu()

func _input(event):
	# Allow skipping with any mouse click or key press
	if event is InputEventKey or event is InputEventMouseButton:
		if event.is_pressed():
			_go_to_main_menu()

func _on_video_stream_player_finished():
	_go_to_main_menu()

var transitioning = false

func _go_to_main_menu():
	if transitioning: return
	transitioning = true
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
