extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = 300.0 # Positive for our custom Z axis
const GRAVITY = 900.0

var is_dead = false
var is_attacking = false
var is_taking_hit = false
var is_invulnerable = false
var invulnerable_timer = 0.0
var health = 999999 # Warrior never dies
var has_dealt_damage = false

var is_jumping = false
var jump_time = 0.0
const JUMP_DURATION = 0.5
const JUMP_HEIGHT = 40.0
var z_velocity = 0.0
var base_sprite_y = -13.0

func _ready():
	add_to_group("player")
	
	# Setup custom input map for "gaming keyboard" layout
	setup_custom_inputs()
	
	# Ensure one-shot animations do not loop endlessly
	var frames = $AnimatedSprite2D.sprite_frames
	if frames:
		frames.set_animation_loop("attack", false)
		frames.set_animation_loop("take hit", false)
		frames.set_animation_loop("death", false)
		
	$AnimatedSprite2D.play("idle")

func setup_custom_inputs():
	var actions = {
		"jump": KEY_SPACE,
		"move_left": KEY_A,
		"move_right": KEY_D,
		"move_up": KEY_W,
		"move_down": KEY_S,
		"attack": KEY_F
	}
	
	for action in actions:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			var ev = InputEventKey.new()
			ev.physical_keycode = actions[action]
			InputMap.action_add_event(action, ev)

func _physics_process(delta: float) -> void:
	# Stop everything if dead
	if is_dead:
		return

	# Handle invincibility frames
	if is_invulnerable:
		invulnerable_timer -= delta
		if invulnerable_timer <= 0:
			is_invulnerable = false
			$AnimatedSprite2D.modulate.a = 1.0
		else:
			$AnimatedSprite2D.modulate.a = 0.5

	# If currently staggered from a hit, stop moving
	if is_taking_hit:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
		move_and_slide()
		return

	var direction_y := Input.get_axis("move_up", "move_down")
	var direction_x := Input.get_axis("move_left", "move_right")
	
	# Y movement (Up/Down) freely without gravity
	if direction_y != 0:
		velocity.y = direction_y * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)

	# Jump (Visual only, returns to normal position)
	if Input.is_action_just_pressed("jump") and not is_jumping:
		is_jumping = true
		jump_time = 0.0
		$AnimatedSprite2D.play("jump")

	if is_jumping:
		jump_time += delta
		if jump_time >= JUMP_DURATION:
			is_jumping = false
			$AnimatedSprite2D.position.y = -13.0
		else:
			var t = jump_time / JUMP_DURATION
			$AnimatedSprite2D.position.y = -13.0 - (4.0 * JUMP_HEIGHT * t * (1.0 - t))

	# Left/right movement
	var direction := direction_x
	if direction:
		velocity.x = direction * SPEED
		$AnimatedSprite2D.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Attack (restarts immediately if pressed again)
	if Input.is_action_just_pressed("attack"):
		is_attacking = true
		has_dealt_damage = false
		$AnimatedSprite2D.stop()
		$AnimatedSprite2D.play("attack")
		
	if is_attacking:
		if $AnimatedSprite2D.frame >= 3 and not has_dealt_damage:
			has_dealt_damage = true
			var enemies = get_tree().get_nodes_in_group("enemy")
			var closest_enemy = null
			var closest_dist = 50.0 # Normal attack range
			for enemy in enemies:
				if enemy == self:
					continue
				if enemy.has_method("take_damage") and "is_dead" in enemy and not enemy.is_dead:
					var dist = global_position.distance_to(enemy.global_position)
					if dist <= closest_dist:
						var dir_to_enemy = sign(enemy.global_position.x - global_position.x)
						var facing_dir = -1 if $AnimatedSprite2D.flip_h else 1
						if dir_to_enemy == facing_dir or dir_to_enemy == 0:
							closest_enemy = enemy
							closest_dist = dist
			if closest_enemy != null:
				closest_enemy.take_damage(25) # Enemy dies in 2 hits

	move_and_slide()
	update_animation(direction_x, direction_y)

func update_animation(direction_x, direction_y):
	# Don't interrupt attack, jump, or taking hit
	if is_attacking or is_jumping or is_taking_hit:
		return

	if direction_x != 0 or direction_y != 0:
		$AnimatedSprite2D.play("run")
	else:
		$AnimatedSprite2D.play("idle")

func take_damage(amount):
	# Warrior is a protector and should never take damage, flinch, or die!
	pass

func die():
	is_dead = true
	$AnimatedSprite2D.play("death")

func _on_animated_sprite_2d_animation_finished():
	# After attack finishes go back to idle
	if $AnimatedSprite2D.animation == "attack":
		is_attacking = false
		$AnimatedSprite2D.play("idle")
	# After take hit go back to idle
	if $AnimatedSprite2D.animation == "take hit":
		is_taking_hit = false
		$AnimatedSprite2D.play("idle")
