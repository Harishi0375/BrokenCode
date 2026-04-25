extends Node

var current_map : String = ""
var player_health : int = 200
var player_max_health : int = 200
var inventory : Array = []

var wave_spawner_script = preload("res://scripts/managers/WaveSpawner.gd")
var hud_script = preload("res://scripts/ui/HUD.gd")

func _ready():
	print("GameManager initialized.")
	# Wait for the main scene to be ready before injecting our HUD and Spawner
	call_deferred("setup_game_systems")

func setup_game_systems():
	var root = get_tree().root
	# The main game node in tile_map.tscn is named "MainGame"
	var main_game = root.get_node_or_null("MainGame")
	if main_game:
		# Add HUD properly
		var hud = hud_script.new()
		main_game.add_child(hud)
		
		# Add Wave Spawner properly
		var spawner = wave_spawner_script.new()
		main_game.add_child(spawner)

# Call this when player takes damage or heals
func update_health(amount: int):
	player_health = clamp(player_health + amount, 0, player_max_health)
	if player_health <= 0:
		game_over()

# Add an item to the global inventory
func add_item(item_name: String):
	if not item_name in inventory:
		inventory.append(item_name)
		print("Picked up item: ", item_name)

# Check if an item is in the inventory
func has_item(item_name: String) -> bool:
	return item_name in inventory

# Game over logic placeholder
func game_over():
	print("Game Over!")
