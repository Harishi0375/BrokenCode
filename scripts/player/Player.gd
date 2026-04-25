extends CharacterBody2D
class_name Player

# Stats
var speed : float = 200.0
var sprint_speed : float = 320.0
var wounded_speed : float = 120.0
var stamina : float = 100.0
var max_stamina : float = 100.0
var stamina_drain_rate : float = 20.0
var stamina_recharge_rate : float = 15.0

# States
var is_wounded : bool = false
var can_attack : bool = true

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta):
	handle_movement(delta)

func handle_movement(delta):
	# Get input direction
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if input_dir.x != 0:
		animated_sprite.flip_h = input_dir.x < 0
	
	# Determine current speed based on state and sprinting
	var current_speed = speed
	if is_wounded:
		current_speed = wounded_speed
	elif Input.is_action_pressed("ui_select") and stamina > 0 and input_dir != Vector2.ZERO: # "ui_select" could be Shift in project settings, usually Space. Let's use it as sprint placeholder.
		current_speed = sprint_speed
		stamina -= stamina_drain_rate * delta
	else:
		stamina = move_toward(stamina, max_stamina, stamina_recharge_rate * delta)
	
	# Apply velocity
	velocity = input_dir * current_speed
	
	if velocity.length() > 0:
		if current_speed == sprint_speed:
			animated_sprite.play("dash")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("idle")
	
	# Move and slide
	move_and_slide()

# Attack placeholder
func attack():
	if not can_attack:
		return
	print("Player attacks!")
	# Implement area detection or raycast for melee damage

# Handle taking damage
func take_damage(amount: int):
	GameManager.update_health(-amount)
	print("Player took ", amount, " damage! Health: ", GameManager.player_health)

# Function to clear wounded state
func heal_wound():
	is_wounded = false
	print("Player is no longer wounded. Speed restored.")
