extends TileMap

# EXPORT THESE: Allows different levels to use different wall tiles!
@export_group("Wall Settings")
@export var wall_source_id: int = 0
@export var wall_set_a_x: int = 29
@export var wall_set_b_x: int = 27
@export var wall_y_range: Vector2i = Vector2i(7, 11)

func _ready():
	# Attach Camera Shake Script
	var cam = get_viewport().get_camera_2d()
	if cam:
		cam.set_script(preload("res://scripts/ui/CameraShake.gd"))
		cam._ready()

	# ---------------------------------------------------------
	# PART 1: SETUP & TILESET PHYSICS
	# ---------------------------------------------------------
	if tile_set.get_physics_layers_count() == 0:
		tile_set.add_physics_layer()
	
	var used_cells = get_used_cells(0) 
	if used_cells.size() == 0: return
		
	var cell_dict = {}
	for cell in used_cells:
		cell_dict[cell] = true

	# ---------------------------------------------------------
	# PART 2: AUTOMATIC WALL GENERATOR
	# ---------------------------------------------------------
	var wall_atlas_coords = []
	for y in range(wall_y_range.x, wall_y_range.y + 1):
		wall_atlas_coords.append(Vector2i(wall_set_a_x, y))
		wall_atlas_coords.append(Vector2i(wall_set_b_x, y))

	var source = tile_set.get_source(wall_source_id) as TileSetAtlasSource
	if source:
		for coords in wall_atlas_coords:
			var tile_data = source.get_tile_data(coords, 0)
			if tile_data:
				if tile_data.get_collision_polygons_count(0) == 0:
					tile_data.add_collision_polygon(0)
				var half_size = tile_set.tile_size / 2
				var points = [
					Vector2(-half_size.x, -half_size.y),
					Vector2(half_size.x, -half_size.y),
					Vector2(half_size.x, half_size.y),
					Vector2(-half_size.x, half_size.y)
				]
				tile_data.set_collision_polygon_points(0, 0, points)

	var sets = [wall_set_a_x, wall_set_b_x]
	var wall_dirs = {
		Vector2i(0, -1): sets[randi() % 2],
		Vector2i(0, 1):  sets[randi() % 2],
		Vector2i(-1, 0): sets[randi() % 2],
		Vector2i(1, 0):  sets[randi() % 2]
	}
	
	var wall_cells = []
	for cell in used_cells:
		for dir in wall_dirs.keys():
			var neighbor = cell + dir
			if not cell_dict.has(neighbor):
				var wall_x = wall_dirs[dir]
				var wall_y = randi_range(wall_y_range.x, wall_y_range.y)
				set_cell(0, neighbor, wall_source_id, Vector2i(wall_x, wall_y))
				wall_cells.append(neighbor)
				cell_dict[neighbor] = true
	
	generate_outer_void_collision(used_cells)

func generate_outer_void_collision(used_cells):
	var min_x = 999999; var max_x = -999999
	var min_y = 999999; var max_y = -999999
	for cell in used_cells:
		min_x = min(min_x, cell.x); max_x = max(max_x, cell.x)
		min_y = min(min_y, cell.y); max_y = max(max_y, cell.y)
		
	var cell_size = tile_set.tile_size
	var boundary_body = StaticBody2D.new()
	boundary_body.name = "OuterVoid"
	add_child(boundary_body)
	
	var rects = [
		Rect2(min_x-20, min_y-20, (max_x-min_x)+40, 19),
		Rect2(min_x-20, max_y+2, (max_x-min_x)+40, 19),
		Rect2(min_x-20, min_y-20, 19, (max_y-min_y)+40),
		Rect2(max_x+2, min_y-20, 19, (max_y-min_y)+40)
	]
	
	for r in rects:
		var shape = CollisionShape2D.new()
		var rs = RectangleShape2D.new()
		var center = Vector2(r.position.x + r.size.x/2, r.position.y + r.size.y/2)
		rs.size = r.size * Vector2(cell_size)
		shape.shape = rs
		shape.position = map_to_local(Vector2i(center.x, center.y))
		boundary_body.add_child(shape)
