extends Node2D

var goblin_scene = preload("res://levels/level_2/scenes/entities/enemies/goblin.tscn")
var skeleton_scene = preload("res://levels/level_2/scenes/entities/enemies/skeleton.tscn")

# EXPORT THESE: Each level can have different difficulty!
@export var max_enemies: int = 60
@export var spawn_interval: float = 1.5
@export var min_spawn_dist: float = 250.0
@export var max_spawn_dist: float = 800.0

var current_enemies = 0
var spawn_timer = 1.0
var tilemap: TileMap
var cached_spawn_points = []

func _ready():
	name = "WaveSpawner"
	await get_tree().process_frame
	await get_tree().process_frame
	
	tilemap = get_parent().get_node_or_null("TileMap")
	if tilemap:
		refresh_spawn_points()

func refresh_spawn_points():
	cached_spawn_points.clear()
	var cells = tilemap.get_used_cells(0)
	for cell in cells:
		cached_spawn_points.append(tilemap.to_global(tilemap.map_to_local(cell)))
	print("Spawner: Cached ", cached_spawn_points.size(), " valid spawn locations.")

func _process(delta):
	if cached_spawn_points.size() == 0: return
	
	spawn_timer -= delta
	if spawn_timer <= 0:
		spawn_timer = spawn_interval
		if current_enemies < max_enemies:
			spawn_enemy()
			if current_enemies < max_enemies:
				spawn_enemy()

func spawn_enemy():
	var player = get_tree().get_first_node_in_group("player")
	if player == null: return

	var best_pos = Vector2.ZERO
	for i in range(20):
		var potential_pos = cached_spawn_points[randi() % cached_spawn_points.size()]
		var d = potential_pos.distance_to(player.global_position)
		if d > min_spawn_dist and d < max_spawn_dist:
			best_pos = potential_pos
			break
	
	if best_pos == Vector2.ZERO:
		best_pos = cached_spawn_points[randi() % cached_spawn_points.size()]

	var is_goblin = (randi() % 2 == 0)
	var enemy_scene = goblin_scene if is_goblin else skeleton_scene
	
	var enemy = enemy_scene.instantiate()
	enemy.global_position = best_pos
	get_parent().add_child(enemy)
	current_enemies += 1
	
	enemy.tree_exiting.connect(func(): current_enemies -= 1)
