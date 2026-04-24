extends Node

# Singleton/Autoload script for managing global game state

var current_map : String = ""
var player_health : int = 100
var player_max_health : int = 100

# Inventory to store collected key items (like "ArmoryKey", "Bandage", etc.)
var inventory : Array = []

signal health_changed(new_health)
signal inventory_updated()

func _ready():
	print("GameManager initialized.")

# Call this when player takes damage or heals
func update_health(amount: int):
	player_health = clamp(player_health + amount, 0, player_max_health)
	emit_signal("health_changed", player_health)
	if player_health <= 0:
		game_over()

# Add an item to the global inventory
func add_item(item_name: String):
	if not item_name in inventory:
		inventory.append(item_name)
		emit_signal("inventory_updated")
		print("Picked up item: ", item_name)

# Check if an item is in the inventory
func has_item(item_name: String) -> bool:
	return item_name in inventory

# Game over logic placeholder
func game_over():
	print("Game Over!")
	# get_tree().change_scene_to_file("res://scenes/ui/GameOver.tscn")
