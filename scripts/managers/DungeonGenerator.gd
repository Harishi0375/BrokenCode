extends Node2D

@export_category("Map Settings")
@export var map_width: int = 100
@export var map_height: int = 100
@export var num_rooms: int = 20
@export var min_room_size: int = 6
@export var max_room_size: int = 14

@export_category("Tile Layers")
@export var floor_layer: TileMapLayer
@export var wall_layer: TileMapLayer

@export_category("Tile Atlas Coordinates")
@export var floor_source_id: int = 0
@export var floor_atlas_coord: Vector2i = Vector2i(0, 0)
@export var wall_source_id: int = 0
@export var wall_atlas_coord: Vector2i = Vector2i(1, 0)

@export_category("Props")
## Add your candle scenes or other props here!
@export var prop_scenes: Array[PackedScene] = []
@export var props_per_room_min: int = 0
@export var props_per_room_max: int = 3

var rooms: Array[Rect2i] = []

func _ready():
	# Automatically generate dungeon when the scene starts
	if floor_layer and wall_layer:
		generate_dungeon()
	else:
		print("DungeonGenerator: Please assign the Floor Layer and Wall Layer in the Inspector!")

func generate_dungeon():
	print("Generating Catacombs...")
	rooms.clear()
	floor_layer.clear()
	wall_layer.clear()
	
	# 1. Generate Rooms
	for i in range(num_rooms * 2): # Try more times in case of overlaps
		if rooms.size() >= num_rooms:
			break
			
		var w = randi_range(min_room_size, max_room_size)
		var h = randi_range(min_room_size, max_room_size)
		var x = randi_range(2, map_width - w - 2)
		var y = randi_range(2, map_height - h - 2)
		
		var new_room = Rect2i(x, y, w, h)
		var can_add = true
		
		# Check overlap (leaving a 1-tile gap)
		for room in rooms:
			var inflated_room = room.grow(1)
			if new_room.intersects(inflated_room):
				can_add = false
				break
				
		if can_add:
			rooms.append(new_room)
			carve_room(new_room)
			
	# 2. Generate Corridors
	for i in range(1, rooms.size()):
		var prev_room_center = rooms[i-1].get_center()
		var curr_room_center = rooms[i].get_center()
		carve_corridor(prev_room_center, curr_room_center)
		
	# 3. Generate Walls around the Floors
	generate_walls()
	
	# 4. Spawn Props
	spawn_props()
	
	print("Generation Complete! Total Rooms: ", rooms.size())

func carve_room(room: Rect2i):
	for x in range(room.position.x, room.end.x):
		for y in range(room.position.y, room.end.y):
			floor_layer.set_cell(Vector2i(x, y), floor_source_id, floor_atlas_coord)

func carve_corridor(start: Vector2i, end: Vector2i):
	var curr_x = start.x
	var curr_y = start.y
	
	# Randomize horizontal first or vertical first
	if randi() % 2 == 0:
		while curr_x != end.x:
			floor_layer.set_cell(Vector2i(curr_x, curr_y), floor_source_id, floor_atlas_coord)
			# Make corridor 2 tiles wide for easy walking
			floor_layer.set_cell(Vector2i(curr_x, curr_y + 1), floor_source_id, floor_atlas_coord)
			curr_x += sign(end.x - curr_x)
		while curr_y != end.y:
			floor_layer.set_cell(Vector2i(curr_x, curr_y), floor_source_id, floor_atlas_coord)
			floor_layer.set_cell(Vector2i(curr_x + 1, curr_y), floor_source_id, floor_atlas_coord)
			curr_y += sign(end.y - curr_y)
	else:
		while curr_y != end.y:
			floor_layer.set_cell(Vector2i(curr_x, curr_y), floor_source_id, floor_atlas_coord)
			floor_layer.set_cell(Vector2i(curr_x + 1, curr_y), floor_source_id, floor_atlas_coord)
			curr_y += sign(end.y - curr_y)
		while curr_x != end.x:
			floor_layer.set_cell(Vector2i(curr_x, curr_y), floor_source_id, floor_atlas_coord)
			floor_layer.set_cell(Vector2i(curr_x, curr_y + 1), floor_source_id, floor_atlas_coord)
			curr_x += sign(end.x - curr_x)

func generate_walls():
	var used_cells = floor_layer.get_used_cells()
	var wall_candidates = {}
	
	# Directions: Up, Down, Left, Right, Diagonals
	var dirs = [Vector2i(0,-1), Vector2i(0,1), Vector2i(-1,0), Vector2i(1,0),
				Vector2i(-1,-1), Vector2i(1,-1), Vector2i(-1,1), Vector2i(1,1)]
				
	for cell in used_cells:
		for d in dirs:
			var neighbor = cell + d
			# If the neighbor is NOT a floor tile, it should be a wall
			if floor_layer.get_cell_source_id(neighbor) == -1:
				wall_candidates[neighbor] = true
				
	for wall_cell in wall_candidates.keys():
		wall_layer.set_cell(wall_cell, wall_source_id, wall_atlas_coord)

func spawn_props():
	if prop_scenes.size() == 0:
		return
		
	# We spawn props as children of the generator node
	for room in rooms:
		var num_props = randi_range(props_per_room_min, props_per_room_max)
		for i in range(num_props):
			var prop_scene = prop_scenes.pick_random()
			if prop_scene:
				var prop = prop_scene.instantiate()
				add_child(prop)
				
				# Pick random tile inside room
				var rx = randi_range(room.position.x + 1, room.end.x - 2)
				var ry = randi_range(room.position.y + 1, room.end.y - 2)
				
				# Convert map tile coordinates to world pixel coordinates
				# Multiplying by tile size (assuming default Godot 4 size of 16x16, but MapToLocal handles this correctly)
				var world_pos = floor_layer.map_to_local(Vector2i(rx, ry))
				prop.global_position = world_pos
