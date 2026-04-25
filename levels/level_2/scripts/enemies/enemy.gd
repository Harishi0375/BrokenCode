extends CharacterBody2D

const CHASE_RANGE = 600.0
const ATTACK_RANGE = 55.0
const ATTACK_COOLDOWN = 1.2
const AVOIDANCE_FORCE = 400.0

var speed = 110.0
var max_health = 30 # Increased base health for better balance
var health = 30

var is_dead = false
var is_attacking = false
var knockback_velocity = Vector2.ZERO
var attack_timer = 0.0
var attack_duration_timer = 0.0 # Safety timer for attack animation
var player = null
var health_bar: ProgressBar

func _ready():
	add_to_group("enemy")
	
	if name.to_lower().contains("skeleton"):
		max_health = 40
		speed = 95.0
	else:
		max_health = 20
		speed = 140.0
	health = max_health

	if has_node("AnimatedSprite2D"):
		var frames = $AnimatedSprite2D.sprite_frames
		if frames:
			frames.set_animation_loop("attack", false)
			frames.set_animation_loop("take_hit", false)
			frames.set_animation_loop("death", false)
		$AnimatedSprite2D.play("idle")
	
	create_health_bar()

func create_health_bar():
	health_bar = ProgressBar.new()
	health_bar.max_value = max_health
	health_bar.value = health
	health_bar.show_percentage = false
	health_bar.custom_minimum_size = Vector2(40, 4)
	health_bar.position = Vector2(-20, -35)
	
	var sb_bg = StyleBoxFlat.new(); sb_bg.bg_color = Color(0.1, 0.1, 0.1, 0.6)
	var sb_fg = StyleBoxFlat.new(); sb_fg.bg_color = Color(0.9, 0.2, 0.2, 1.0)
	health_bar.add_theme_stylebox_override("background", sb_bg)
	health_bar.add_theme_stylebox_override("fill", sb_fg)
	add_child(health_bar)
	health_bar.hide()

func _physics_process(delta: float) -> void:
	if is_dead: return
		
	if attack_timer > 0: attack_timer -= delta
	if attack_duration_timer > 0:
		attack_duration_timer -= delta
		if attack_duration_timer <= 0:
			is_attacking = false # Safety release
	
	# Reset movement if knocked back
	if knockback_velocity.length() > 10:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 1000 * delta)
	else:
		handle_ai_movement(delta)
		apply_avoidance(delta)

	if velocity.length() > 0:
		move_and_slide()
	
	update_animation()

func apply_avoidance(delta):
	var enemies = get_tree().get_nodes_in_group("enemy")
	var push = Vector2.ZERO
	for e in enemies:
		if e == self or e.is_dead: continue
		var dist = global_position.distance_to(e.global_position)
		if dist < 45.0:
			push += (global_position - e.global_position).normalized() * (AVOIDANCE_FORCE / (dist + 1.0))
	velocity += push * delta * 15.0

func handle_ai_movement(_delta):
	# Refresh player reference if lost
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		if player == null: return

	if is_attacking:
		velocity = Vector2.ZERO
		return

	var dist = global_position.distance_to(player.global_position)
	
	if dist <= ATTACK_RANGE:
		velocity = Vector2.ZERO
		if attack_timer <= 0 and not player.is_dead:
			perform_attack()
	elif dist <= CHASE_RANGE:
		var dir = global_position.direction_to(player.global_position)
		velocity = dir * speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed)

func perform_attack():
	is_attacking = true
	attack_timer = ATTACK_COOLDOWN
	attack_duration_timer = 0.8 # Assume attack takes 0.8s max
	if has_node("AnimatedSprite2D"): $AnimatedSprite2D.play("attack")
	if player.has_method("take_damage"):
		player.take_damage(10)

func update_animation():
	if is_attacking or not has_node("AnimatedSprite2D"): return

	if velocity.length() > 10:
		$AnimatedSprite2D.flip_h = velocity.x < 0
		var anim = "run" if $AnimatedSprite2D.sprite_frames.has_animation("run") else "walk"
		$AnimatedSprite2D.play(anim)
	else:
		$AnimatedSprite2D.play("idle")

func take_damage(amount):
	if is_dead: return
	health -= amount
	health_bar.show()
	health_bar.value = health
	
	# Stop attacking if hit hard (interrupt)
	is_attacking = false
	attack_duration_timer = 0.0
	
	# Fresh player reference
	player = get_tree().get_first_node_in_group("player")
	if player:
		var dir = player.global_position.direction_to(global_position)
		knockback_velocity = dir * 450.0 # Stronger knockback
	
	if health <= 0:
		die()
	elif has_node("AnimatedSprite2D"):
		if $AnimatedSprite2D.sprite_frames.has_animation("take_hit"):
			$AnimatedSprite2D.play("take_hit")

func die():
	is_dead = true
	velocity = Vector2.ZERO
	health_bar.hide()
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	if has_node("AnimatedSprite2D"): $AnimatedSprite2D.play("death")

func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "attack":
		is_attacking = false
		attack_duration_timer = 0.0
	elif $AnimatedSprite2D.animation == "death":
		queue_free()
