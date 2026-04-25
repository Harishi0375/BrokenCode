extends CharacterBody2D

const SPEED = 80.0
const ATTACK_RANGE = 40.0
const CHASE_RANGE = 400.0
const ATTACK_COOLDOWN = 1.2

var is_dead = false
var is_attacking = false
var health = 10
var max_health = 10

var player = null
var health_bar: ProgressBar
var attack_timer = 0.0

func _ready():
	add_to_group("enemy")
	
	# Determine health based on enemy type name
	if name.to_lower().contains("skeleton"):
		max_health = 20
	else:
		max_health = 10
	health = max_health

	var frames = $AnimatedSprite2D.sprite_frames
	if frames:
		frames.set_animation_loop("attack", false)
		frames.set_animation_loop("take_hit", false)
		frames.set_animation_loop("death", false)

	$AnimatedSprite2D.play("idle")
	
	# Create Health Bar
	health_bar = ProgressBar.new()
	health_bar.max_value = max_health
	health_bar.value = health
	health_bar.show_percentage = false
	health_bar.custom_minimum_size = Vector2(40, 5)
	health_bar.position = Vector2(-20, -30)
	
	# Style the health bar
	var sb_bg = StyleBoxFlat.new()
	sb_bg.bg_color = Color(0.2, 0.2, 0.2, 0.8)
	var sb_fg = StyleBoxFlat.new()
	sb_fg.bg_color = Color(0.9, 0.1, 0.1, 1.0)
	health_bar.add_theme_stylebox_override("background", sb_bg)
	health_bar.add_theme_stylebox_override("fill", sb_fg)
	
	add_child(health_bar)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
		
	if attack_timer > 0:
		attack_timer -= delta
		
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		if player == null:
			update_animation(0, 0)
			return

	var distance = global_position.distance_to(player.global_position)
	var direction_x = 0
	var direction_y = 0

	if distance <= ATTACK_RANGE:
		velocity = Vector2.ZERO
		if attack_timer <= 0 and not player.is_dead:
			is_attacking = true
			attack_timer = ATTACK_COOLDOWN
			$AnimatedSprite2D.play("attack")
			
			# Deal damage to player
			if player.has_method("take_damage"):
				player.take_damage(10)
	elif distance <= CHASE_RANGE and not is_attacking:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * SPEED
		direction_x = direction.x
		direction_y = direction.y
		
		if direction_x != 0:
			$AnimatedSprite2D.flip_h = direction_x < 0
	elif not is_attacking:
		velocity = Vector2.ZERO

	if not is_attacking:
		move_and_slide()
		update_animation(direction_x, direction_y)

func update_animation(direction_x, direction_y):
	if is_attacking:
		return

	if direction_x != 0 or direction_y != 0:
		if $AnimatedSprite2D.sprite_frames.has_animation("run"):
			$AnimatedSprite2D.play("run")
		else:
			$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.play("idle")

func take_damage(amount):
	if is_dead: return
	health -= amount
	health_bar.value = health
	
	if health <= 0:
		die()
	else:
		if not is_attacking:
			if $AnimatedSprite2D.sprite_frames.has_animation("take_hit"):
				$AnimatedSprite2D.play("take_hit")
			elif $AnimatedSprite2D.sprite_frames.has_animation("take hit"):
				$AnimatedSprite2D.play("take hit")

func die():
	is_dead = true
	velocity = Vector2.ZERO
	health_bar.hide()
	
	# The skeleton and goblin sprites have a "Death" animation
	if $AnimatedSprite2D.sprite_frames.has_animation("death"):
		$AnimatedSprite2D.play("death")
	else:
		queue_free()

func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "attack":
		is_attacking = false
		$AnimatedSprite2D.play("idle")
	elif $AnimatedSprite2D.animation == "take_hit" or $AnimatedSprite2D.animation == "take hit":
		$AnimatedSprite2D.play("idle")
	elif $AnimatedSprite2D.animation == "death":
		queue_free() # Remove from scene after death animation finishes
