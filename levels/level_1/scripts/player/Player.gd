extends CharacterBody2D

const BASE_SPEED = 180.0
const SPRINT_SPEED = 280.0
const DASH_SPEED = 800.0
const DASH_DURATION = 0.15
const DASH_COOLDOWN = 1.0

var is_dead = false
var is_attacking = false
var is_dashing = false
var health = 200 
var max_health = 200

var dash_timer = 0.0
var dash_cooldown_timer = 0.0

var attack_area: Area2D
var attack_shape: CollisionShape2D
var health_bar: ProgressBar

func _ready():
	add_to_group("player")
	setup_custom_inputs()
	
	if has_node("AnimatedSprite2D"):
		var frames = $AnimatedSprite2D.sprite_frames
		if frames:
			frames.set_animation_loop("attack", false)
			frames.set_animation_loop("take_hit", false)
			frames.set_animation_loop("death", false)
		$AnimatedSprite2D.play("idle")
	
	# Create Attack Hitbox (Larger AOE)
	attack_area = Area2D.new()
	attack_area.name = "AttackArea"
	attack_shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(80, 80) # Increased size for better AOE
	attack_shape.shape = rect
	attack_shape.position = Vector2(40, 0)
	attack_area.add_child(attack_shape)
	add_child(attack_area)
	
	create_health_bar()
	
	call_deferred("update_hud")

func create_health_bar():
	health_bar = ProgressBar.new()
	health_bar.max_value = max_health
	health_bar.value = health
	health_bar.show_percentage = false
	health_bar.custom_minimum_size = Vector2(50, 5)
	health_bar.position = Vector2(-25, -40)
	
	var sb_bg = StyleBoxFlat.new(); sb_bg.bg_color = Color(0.1, 0.1, 0.1, 0.6)
	var sb_fg = StyleBoxFlat.new(); sb_fg.bg_color = Color(0.1, 0.8, 0.2, 1.0)
	health_bar.add_theme_stylebox_override("background", sb_bg)
	health_bar.add_theme_stylebox_override("fill", sb_fg)
	add_child(health_bar)

func setup_custom_inputs():
	var acts = ["move_left", "move_right", "move_up", "move_down", "attack", "sprint", "dash"]
	for a in acts:
		if not InputMap.has_action(a): InputMap.add_action(a)
	
	_bind_key("move_left", KEY_A); _bind_key("move_left", KEY_LEFT)
	_bind_key("move_right", KEY_D); _bind_key("move_right", KEY_RIGHT)
	_bind_key("move_up", KEY_W); _bind_key("move_up", KEY_UP)
	_bind_key("move_down", KEY_S); _bind_key("move_down", KEY_DOWN)
	_bind_key("attack", KEY_F); _bind_key("sprint", KEY_SHIFT)
	_bind_key("dash", KEY_SPACE)

func _bind_key(action, keycode):
	var ev = InputEventKey.new()
	ev.physical_keycode = keycode
	if not InputMap.action_has_event(action, ev): InputMap.action_add_event(action, ev)

func _physics_process(delta: float) -> void:
	if is_dead: return

	if dash_timer > 0:
		dash_timer -= delta
		if dash_timer <= 0: is_dashing = false
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	var input_dir = Vector2.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): input_dir.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): input_dir.y += 1
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): input_dir.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): input_dir.x += 1
	input_dir = input_dir.normalized()

	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0 and input_dir != Vector2.ZERO:
		is_dashing = true
		dash_timer = DASH_DURATION
		dash_cooldown_timer = DASH_COOLDOWN
	
	var current_speed = BASE_SPEED
	if is_dashing: current_speed = DASH_SPEED
	elif Input.is_action_pressed("sprint"): current_speed = SPRINT_SPEED
	
	if not is_attacking or is_dashing:
		velocity = input_dir * current_speed
	else:
		velocity = input_dir * (BASE_SPEED * 0.1)

	if input_dir.x != 0:
		if has_node("AnimatedSprite2D"): $AnimatedSprite2D.flip_h = input_dir.x < 0
		attack_shape.position.x = -40 if input_dir.x < 0 else 40

	if Input.is_action_just_pressed("attack") and not is_attacking and not is_dashing:
		start_attack()

	move_and_slide()
	update_animation(input_dir)

func start_attack():
	is_attacking = true
	if has_node("AnimatedSprite2D"): $AnimatedSprite2D.play("attack")
	
	# AOE Attack logic: Hit ALL overlapping enemies
	var overlapping_bodies = attack_area.get_overlapping_bodies()
	var hit_count = 0
	for body in overlapping_bodies:
		if body.is_in_group("enemy") and body.has_method("take_damage"):
			body.take_damage(15) # Increased damage to 15
			hit_count += 1
	
	if hit_count > 0:
		apply_screen_shake(0.2, 5)

func update_animation(input_dir):
	if is_attacking or not has_node("AnimatedSprite2D"): return
	if input_dir.length() > 0: $AnimatedSprite2D.play("run")
	else: $AnimatedSprite2D.play("idle")

func take_damage(amount):
	if is_dead: return
	health -= amount
	health_bar.value = health
	update_hud()
	apply_screen_shake(0.3, 10)
	if health <= 0: 
		die()
	else:
		if not is_attacking and has_node("AnimatedSprite2D"):
			$AnimatedSprite2D.play("take_hit")

func apply_screen_shake(duration, intensity):
	var cam = get_viewport().get_camera_2d()
	if cam and cam.has_method("shake"):
		cam.shake(duration, intensity)

func die():
	is_dead = true
	velocity = Vector2.ZERO
	health_bar.hide()
	if has_node("AnimatedSprite2D"): $AnimatedSprite2D.play("death")
	
	# Trigger Level 2 death dialogue if available
	var dialogue_ui = get_tree().get_first_node_in_group("level2_dialogue")
	if dialogue_ui:
		var lines: Array[String] = ["[N] — \"How do you manage to die in your own game? Didn't you know this was coming?\"", "[P] — \"I BUILT IT I DIDN'T PLAYTEST IT there's a difference!\""]
		dialogue_ui.show_dialogue(lines)
		await dialogue_ui.dialogue_finished
		
	if GameManager:
		GameManager.on_player_died()

func update_hud():
	var main = get_tree().current_scene
	if main and main.has_node("HUD"):
		var hud = main.get_node("HUD")
		if hud.has_method("update_health"):
			hud.update_health(health, max_health)

func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "attack":
		is_attacking = false
