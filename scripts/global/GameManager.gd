extends Node

var current_lives : int = 3
var player_health : int = 200
var player_max_health : int = 200
var inventory : Array = []

var wave_spawner_script = preload("res://levels/level_2/scripts/managers/WaveSpawner.gd")
var hud_script = preload("res://levels/level_2/scripts/ui/HUD.gd")

func _ready():
	print("GameManager: Initialized.")
	RenderingServer.set_default_clear_color(Color.BLACK)
	get_tree().node_added.connect(_on_node_added)
	call_deferred("setup_game_systems")

func _on_node_added(node):
	if node.name == "MainGame":
		call_deferred("setup_game_systems")

func setup_game_systems():
	var main_game = get_tree().current_scene
	if main_game == null: return
	if not main_game.has_node("TileMap"): return

	if main_game.has_node("HUD"): return

	print("GameManager: Injecting HUD.")
	
	var hud = hud_script.new()
	hud.name = "HUD"
	# Ensure HUD keeps working when game is paused
	hud.process_mode = Node.PROCESS_MODE_ALWAYS
	main_game.add_child(hud)
	
	var spawner = wave_spawner_script.new()
	spawner.name = "WaveSpawner"
	main_game.add_child(spawner)
	
	call_deferred("update_hud_state")

func update_hud_state():
	var hud = get_tree().current_scene.get_node_or_null("HUD")
	if hud:
		hud.update_health(player_health, player_max_health)
		hud.update_lives(current_lives)

func on_player_died():
	current_lives -= 1
	var hud = get_tree().current_scene.get_node_or_null("HUD")
	if hud:
		hud.update_lives(current_lives)
		
	# Pause the game so enemies stop attacking
	get_tree().paused = true
	
	if current_lives > 0:
		if hud: hud.show_death_screen(false)
	else:
		if hud: hud.show_death_screen(true)

func on_victory():
	# Pause the game so enemies stop attacking
	get_tree().paused = true
	
	var hud = get_tree().current_scene.get_node_or_null("HUD")
	if hud:
		hud.show_victory_screen()

func respawn_player():
	get_tree().paused = false
	player_health = player_max_health
	get_tree().reload_current_scene()

func restart_game():
	get_tree().paused = false
	current_lives = 3
	player_health = player_max_health
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
