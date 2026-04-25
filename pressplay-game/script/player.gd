extends CharacterBody2D

const SPEED = 130.0

var is_dead = false
var is_attacking = false
var health = 200 # 20 hits of 10 damage
var max_health = 200

var attack_area: Area2D
var attack_shape: CollisionShape2D

func _ready():
	add_to_group("player")
	
	setup_custom_inputs()
	
	var frames = $AnimatedSprite2D.sprite_frames
	if frames:
		frames.set_animation_loop("attack", false)
		frames.set_animation_loop("take_hit", false)
		frames.set_animation_loop("death", false)
		
	$AnimatedSprite2D.play("idle")
	
	# Create Attack Hitbox for Knife ability
	attack_area = Area2D.new()
	attack_area.name = "AttackArea"
	attack_shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(50, 50)
	attack_shape.shape = rect
	attack_shape.position = Vector2(25, 0) # Defaults to attacking right
	attack_area.add_child(attack_shape)
	add_child(attack_area)
	
	# Force GameManager to update HUD if it exists
	if get_tree().root.has_node("MainGame/HUD"):
		get_tree().root.get_node("MainGame/HUD").update_health(health, max_health)

func setup_custom_inputs():
	var actions = {
		"move_left": KEY_A,
		"move_right": KEY_D,
		"move_up": KEY_W,
		"move_down": KEY_S,
		"attack": KEY_F # Knife ability on button F
	}
	
	for action in actions:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			
		var ev = InputEventKey.new()
		ev.physical_keycode = actions[action]
		if not InputMap.action_has_event(action, ev):
			InputMap.action_add_event(action, ev)

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	var direction_y := Input.get_axis("move_up", "move_down")
	var direction_x := Input.get_axis("move_left", "move_right")
	
	# Y movement
	if direction_y != 0:
		velocity.y = direction_y * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)

	# Left/right movement
	var direction := direction_x
	if direction:
		velocity.x = direction * SPEED
		$AnimatedSprite2D.flip_h = direction < 0
		# Flip hitbox so we hit the direction we are facing
		attack_shape.position.x = -25 if direction < 0 else 25
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Attack
	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
		$AnimatedSprite2D.stop()
		$AnimatedSprite2D.play("attack")
		
		# Deal damage instantly to enemies in front of us
		var overlapping_bodies = attack_area.get_overlapping_bodies()
		for body in overlapping_bodies:
			if body.is_in_group("enemy") and body.has_method("take_damage"):
				body.take_damage(10)

	move_and_slide()
	update_animation(direction_x, direction_y)

func update_animation(direction_x, direction_y):
	if is_attacking:
		return

	if direction_x != 0 or direction_y != 0:
		$AnimatedSprite2D.play("run")
	else:
		$AnimatedSprite2D.play("idle")

func take_damage(amount):
	health -= amount
	
	# Update HUD
	if get_tree().root.has_node("MainGame/HUD"):
		get_tree().root.get_node("MainGame/HUD").update_health(health, max_health)
		
	if health <= 0:
		die()
	else:
		if not is_attacking: # Don't interrupt attacks
			$AnimatedSprite2D.play("take_hit")

func die():
	is_dead = true
	$AnimatedSprite2D.play("death")

func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "attack":
		is_attacking = false
		$AnimatedSprite2D.play("idle")
	if $AnimatedSprite2D.animation == "take_hit":
		$AnimatedSprite2D.play("idle")
