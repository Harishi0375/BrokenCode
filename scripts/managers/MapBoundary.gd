extends TileMap

func _ready():
	# ---------------------------------------------------------
	# PART 1: SETUP
	# ---------------------------------------------------------
	var cell_size = tile_set.tile_size
	# Get all the floor tiles you painted
	var used_cells = get_used_cells(0) 
	
	var cell_dict = {}
	for cell in used_cells:
		cell_dict[cell] = true

	# ---------------------------------------------------------
	# PART 2: INVISIBLE COLLISION BOUNDARIES
	# ---------------------------------------------------------
	var boundary_body = StaticBody2D.new()
	boundary_body.name = "AutoBoundary"
	add_child(boundary_body)
	
	var edges = [
		{"dir": Vector2i(0, -1), "p1": Vector2(0, 0), "p2": Vector2(1, 0)}, # Top
		{"dir": Vector2i(0, 1),  "p1": Vector2(0, 1), "p2": Vector2(1, 1)}, # Bottom
		{"dir": Vector2i(-1, 0), "p1": Vector2(0, 0), "p2": Vector2(0, 1)}, # Left
		{"dir": Vector2i(1, 0),  "p1": Vector2(1, 0), "p2": Vector2(1, 1)}  # Right
	]
	
	for cell in used_cells:
		for edge in edges:
			var neighbor = cell + edge["dir"]
			if not cell_dict.has(neighbor):
				var shape = CollisionShape2D.new()
				var segment = SegmentShape2D.new()
				var top_left = map_to_local(cell) - (Vector2(cell_size) / 2.0)
				segment.a = top_left + (edge["p1"] * Vector2(cell_size))
				segment.b = top_left + (edge["p2"] * Vector2(cell_size))
				shape.shape = segment
				shape.debug_color = Color(1, 0, 0, 0.5) 
				boundary_body.add_child(shape)

	# ---------------------------------------------------------
	# PART 3: AUTOMATIC WALL TILE GENERATOR
	# ---------------------------------------------------------
	# mainlevbuild.png is source 0 in our tileset
	var source_id = 0 
	
	var set_a_x = 29
	var set_b_x = 27
	
	# Randomly flip a coin to pick Set A or Set B for each "side" of the map
	var top_set = set_a_x if randi() % 2 == 0 else set_b_x
	var bottom_set = set_a_x if randi() % 2 == 0 else set_b_x
	var left_set = set_a_x if randi() % 2 == 0 else set_b_x
	var right_set = set_a_x if randi() % 2 == 0 else set_b_x
	
	var directions = {
		Vector2i(0, -1): top_set,
		Vector2i(0, 1): bottom_set,
		Vector2i(-1, 0): left_set,
		Vector2i(1, 0): right_set
	}
	
	for cell in used_cells:
		for dir in directions.keys():
			var neighbor = cell + dir
			# If it's an empty edge cell, draw a wall!
			if not cell_dict.has(neighbor):
				var chosen_set_x = directions[dir]
				# Pick a random Y variation from 7 to 11
				var random_y = randi_range(7, 11)
				set_cell(0, neighbor, source_id, Vector2i(chosen_set_x, random_y))
				# Mark as drawn so overlapping corners don't place two tiles
				cell_dict[neighbor] = true
