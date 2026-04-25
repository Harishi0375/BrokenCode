extends Node2D

var goblin_scene = preload("res://pressplay-game/scenes/goblin.tscn")
var skeleton_scene = preload("res://pressplay-game/scenes/skeleton.tscn")

var max_goblins = 5
var max_skeletons = 5

var current_goblins = 0
var current_skeletons = 0

var spawn_timer = 0.0
var spawn_interval = 3.0 # Spawn an enemy every 3 seconds

var tilemap: TileMap
var valid_spawn_cells = []

func _ready():
	name = "WaveSpawner"
	print("WaveSpawner _ready called")
	# Wait for the TileMap to be fully loaded and walls to be drawn
	await get_tree().process_frame
	
	tilemap = get_parent().get_node_or_null("TileMap")
	if tilemap:
		valid_spawn_cells.clear()
		for cell in tilemap.get_used_cells(0):
			var atlas_coord = tilemap.get_cell_atlas_coords(0, cell)
			# Exclude the wall tiles (X = 29 and X = 27)
			if atlas_coord.x != 29 and atlas_coord.x != 27:
				valid_spawn_cells.append(cell)
		print("Valid spawn cells found: ", valid_spawn_cells.size())

func _process(delta):
	if valid_spawn_cells.size() == 0:
		return
		
	if current_goblins >= max_goblins and current_skeletons >= max_skeletons:
		return
		
	spawn_timer -= delta
	if spawn_timer <= 0:
		spawn_timer = spawn_interval
		spawn_random_enemy()

func find_closest_valid_cell(world_pos: Vector2) -> Vector2i:
	var closest_cell = valid_spawn_cells[0]
	var min_dist = INF
	
	for cell in valid_spawn_cells:
		var cell_world_pos = tilemap.to_global(tilemap.map_to_local(cell))
		var dist = cell_world_pos.distance_squared_to(world_pos)
		if dist < min_dist:
			min_dist = dist
			closest_cell = cell
			
	return closest_cell

func spawn_random_enemy():
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	var spawn_goblin = false
	if current_goblins < max_goblins and current_skeletons < max_skeletons:
		spawn_goblin = (randi() % 2 == 0)
	elif current_goblins < max_goblins:
		spawn_goblin = true
	else:
		spawn_goblin = false
		
	var target_cell = valid_spawn_cells[0]
	
	if spawn_goblin:
		# GOBLIN: Spawn where the player is going
		var look_ahead = player.global_position
		if player.velocity != Vector2.ZERO:
			look_ahead += player.velocity.normalized() * 250.0
		else:
			# If standing still, spawn nearby
			var angle = randf() * TAU
			look_ahead += Vector2(cos(angle), sin(angle)) * 250.0
			
		target_cell = find_closest_valid_cell(look_ahead)
	else:
		# SKELETON: Spawn near, but not too close (Donut shape)
		var angle = randf() * TAU
		var distance = randf_range(200.0, 400.0)
		var spawn_pos = player.global_position + Vector2(cos(angle), sin(angle)) * distance
		
		target_cell = find_closest_valid_cell(spawn_pos)
		
	var enemy = goblin_scene.instantiate() if spawn_goblin else skeleton_scene.instantiate()
	
	# Convert grid coords to world position
	enemy.global_position = tilemap.to_global(tilemap.map_to_local(target_cell))
	
	# Add to the main game
	get_parent().add_child(enemy)
	
	if spawn_goblin:
		current_goblins += 1
	else:
		current_skeletons += 1
