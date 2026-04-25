extends CharacterBody2D

@export var move_speed : float = 150.0
var is_attacking : bool = false 

# Make sure your AnimatedSprite2D node is named exactly "AnimatedSprite2D"
@onready var _animated_sprite = $AnimatedSprite2D

func _physics_process(_delta):
	# If the character is attacking, we stop movement and skip the rest
	if is_attacking:
		return

	# 1. Attack Input (Check if "attack" is pressed)
	if Input.is_action_just_pressed("slash"):
		slash()
		return

	# 2. Movement Input
	var input_direction = Input.get_vector("left", "right", "up", "down")
	
	# 3. Apply Velocity
	velocity = input_direction * move_speed
	move_and_slide()
	
	# 4. Update Animations based on movement
	update_animations(input_direction)


func update_animations(direction: Vector2):
	if direction != Vector2.ZERO:
		# Choose walk animation based on dominant direction
		if abs(direction.x) > abs(direction.y):
			if direction.x > 0:
				_animated_sprite.play("walk_right")
			else:
				_animated_sprite.play("walk_left")
		else:
			if direction.y > 0:
				_animated_sprite.play("walk_down")
			else:
				_animated_sprite.play("walk_up")
	else:
		# If stopped, play idle animation based on last movement
		var current_anim = _animated_sprite.animation
		if "right" in current_anim:
			_animated_sprite.play("idle_right")
		elif "left" in current_anim:
			_animated_sprite.play("idle_left")
		elif "up" in current_anim:
			_animated_sprite.play("idle_up")
		elif "down" in current_anim:
			_animated_sprite.play("idle_down")


func slash():
	is_attacking = true
	
	# Determine which attack animation to play based on current facing direction
	var current_anim = _animated_sprite.animation
	var direction = "down" # Default direction
	
	if "right" in current_anim:
		direction = "right"
	elif "left" in current_anim:
		direction = "left"
	elif "up" in current_anim:
		direction = "up"
	
	_animated_sprite.play("slash_" + direction)


# This function runs automatically when ANY animation ends
func _on_animated_sprite_2d_animation_finished():
	# We check if the finished animation was an attack
	if "slash" in _animated_sprite.animation:
		is_attacking = false # Character can move again
