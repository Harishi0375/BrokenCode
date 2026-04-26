extends CharacterBody2D

@export var speed : float = 400.0
@export var jump_velocity : float = -600.0
@export var max_lives : int = 5

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var spawn_position : Vector2
var current_lives : int
var is_dead : bool = false
var just_teleported : bool = false
var dying_scene_path = "" # yet to add: path to the dying scene
var is_invulnerable : bool = false
var game_over_ui_scene_path = "res://scenes/game_over.tscn"

var hud : CanvasLayer

func _ready():
	add_to_group("player")
	# We use call_deferred to ensure global_position is correct after placement in the scene
	call_deferred("set_spawn")
	
	# Instantiate HUD at the scene level so it's not affected by player movement/scaling
	var hud_scene = load("res://scenes/hud.tscn")
	if hud_scene:
		hud = hud_scene.instantiate()
		get_tree().current_scene.call_deferred("add_child", hud)
		hud.add_to_group("hud")
		# We need to wait for the next frame or use call_deferred for the initial update
		hud.call_deferred("update_hearts", max_lives)

	# Setup HurtBox
	var hurt_box = Area2D.new()
	hurt_box.name = "HurtBox"
	hurt_box.collision_layer = 0
	hurt_box.collision_mask = 2 # Detect Enemies on layer 2
	add_child(hurt_box)
	
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(40, 50) # Larger area for better detection
	collision.shape = shape
	hurt_box.add_child(collision)
	
	hurt_box.body_entered.connect(_on_hurt_box_body_entered)
	print("Player initialized with HUD and HurtBox")

func set_spawn():
	spawn_position = global_position
	current_lives = max_lives
	if hud:
		hud.update_hearts(current_lives)
	print("Spawn position set to: ", spawn_position)

func set_teleport_immunity():
	just_teleported = true
	await get_tree().create_timer(1.0).timeout
	just_teleported = false

func _physics_process(delta):
	if is_dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	if not is_on_floor():
		velocity.y += gravity * delta
	if (Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_UP) or Input.is_action_just_pressed("ui_accept")) and is_on_floor():
		velocity.y = jump_velocity
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction == 0:
		if Input.is_key_pressed(KEY_A): direction = -1
		elif Input.is_key_pressed(KEY_D): direction = 1
	if direction != 0:
		velocity.x = direction * speed
		$AnimatedSprite2D.flip_h = (direction < 0)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	move_and_slide()
	update_animation(direction)

func update_animation(direction):
	if is_dead:
		if $AnimatedSprite2D.animation != "death":
			$AnimatedSprite2D.play("death")
		return
	if not is_on_floor():
		$AnimatedSprite2D.play("jump_right")
	elif direction != 0:
		$AnimatedSprite2D.play("run_right")
	else:
		$AnimatedSprite2D.play("idle_right")

func take_damage():
	if is_dead or is_invulnerable:
		return
	print("Player took damage! Lives left: ", current_lives - 1)
	current_lives -= 1
	
	# Update HUD via group
	get_tree().call_group("hud", "update_hearts", current_lives)
	
	if current_lives <= 0:
		die()
	else:
		respawn()

func die():
	if is_dead:
		return
	print("Player died - Game Over triggered")
	is_dead = true
	velocity = Vector2.ZERO
	$AnimatedSprite2D.play("death")

func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "death":
		if current_lives <= 0:
			game_over()

func respawn():
	is_dead = true
	is_invulnerable = true
	print("Respawning...")
	$AnimatedSprite2D.play("death") # Show death animation briefly
	await get_tree().create_timer(1.0).timeout
	global_position = spawn_position
	is_dead = false
	$AnimatedSprite2D.play("idle_right")
	print("Respawned at: ", global_position)
	
	# Flicker effect for invulnerability
	for i in range(5):
		$AnimatedSprite2D.modulate.a = 0.5
		await get_tree().create_timer(0.2).timeout
		$AnimatedSprite2D.modulate.a = 1.0
		await get_tree().create_timer(0.2).timeout
	
	is_invulnerable = false
	print("Invulnerability ended")

func game_over():
	print("Showing Game Over Screen")
	get_tree().paused = true # Pause everything
	if not FileAccess.file_exists(game_over_ui_scene_path):
		print("Error: Scene file does not exist at ", game_over_ui_scene_path)
		return
		
	var game_over_scene = ResourceLoader.load(game_over_ui_scene_path)
	if game_over_scene:
		var go = game_over_scene.instantiate()
		get_tree().current_scene.add_child(go)
	else:
		print("Error: ResourceLoader failed to load ", game_over_ui_scene_path)

func _on_hurt_box_body_entered(body):
	if body.is_in_group("enemy"):
		print("Enemy contact: ", body.name)
		take_damage()
