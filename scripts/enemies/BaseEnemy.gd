extends CharacterBody2D
class_name BaseEnemy

@export var max_health : int = 50
@export var speed : float = 100.0
@export var damage : int = 10

var health : int

# Reference to the player (assigned dynamically or via groups)
var player = null

func _ready():
	health = max_health
	# Simple way to find player if they are in the "Player" group
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0]

func _physics_process(delta):
	# Base movement logic to be overridden by subclasses
	pass

# Function to handle taking damage
func take_damage(amount: int):
	health -= amount
	print(name, " took ", amount, " damage. Health: ", health)
	if health <= 0:
		die()

# Function to handle death
func die():
	print(name, " died.")
	queue_free() # Remove from scene

# Utility function to damage player if in contact
func _on_body_entered(body: Node2D):
	if body is Player:
		body.take_damage(damage)
