extends Node

var x: int = 6
var y: int = 6

signal generation_finished(grid: Array[Array])

func render_dungeon(grid: Array[Array]):
	var x: int = grid[0].size()
	var y: int = grid.size()
	var img: Image = Image.create(x, y, false, Image.FORMAT_RGB8)
	var rownum: int = 0
	for row in grid:
		var cellnum: int = 0
		for cell in row:
			var color: Color
			if cell.type == Room.room_type.EMPTY:
				color = Color(1, 1, 1)  # White
			elif cell.type == Room.room_type.START:
				color = Color(1, 0, 0)  # Red
			elif cell.type == Room.room_type.END:
				color = Color(0, 1, 0)  # Green
			elif cell.type == Room.room_type.GENERIC:
				color = Color(0, 0, 0)  # Black
			elif cell.type == Room.room_type.MAIN_BRANCH:
				color = Color(0, 0, 1)  # Blue
			img.set_pixel(cellnum, rownum, color)
			cellnum += 1
		rownum += 1
	img.save_png("res://dungeon_" + str(Time.get_ticks_usec()) + ".png")

func make_grid(sizeX: int, sizeY: int) -> Array[Array]:
	var grid: Array[Array] = []
	for i in range(sizeY):
		var row: Array = []
		for j in range(sizeX):
			row.append(Room.new(Room.room_type.EMPTY, []))
		grid.append(row)
	return grid

func generate_dungeon(grid: Array[Array], branch_length: int, dead_end_chance: float, dead_end_max: int) -> Variant:
	var _grid: Array[Array] = grid
	var x_size: int = _grid[0].size()
	var y_size: int = _grid.size()

	var last_coordinate: Array = [0, 0]
	var current_coordinate: Array = [floor(float(y_size) / 2.0), floor(float(x_size) / 2.0)]
	var current_x: int = current_coordinate[1]
	var current_y: int = current_coordinate[0]

	# Generate starting room
	_grid[current_y][current_x] = Room.new(Room.room_type.START, [])

	for i in range(branch_length):
		var directions: Array[Array] = get_directions(x_size, y_size, current_x, current_y, _grid)

		if directions.size() > 0:
			last_coordinate = current_coordinate
			current_coordinate = directions[randi_range(0, directions.size() - 1)]
			current_x = current_coordinate[1]
			current_y = current_coordinate[0]

			var dx = current_x - last_coordinate[1]
			var dy = current_y - last_coordinate[0]

			var room_dir: Room.direction
			var inverse_room_dir: Room.direction

			if dy < 0:
				room_dir = Room.direction.NORTH
				inverse_room_dir = Room.direction.SOUTH
			elif dy > 0:
				room_dir = Room.direction.SOUTH
				inverse_room_dir = Room.direction.NORTH
			elif dx < 0:
				room_dir = Room.direction.WEST
				inverse_room_dir = Room.direction.EAST
			elif dx > 0:
				room_dir = Room.direction.EAST
				inverse_room_dir = Room.direction.WEST

			print("GEN001 | (" + str(current_x) + ", " + str(current_y) + ") with direction " + str(inverse_room_dir) + " invoked (" + str(last_coordinate[1]) + ", " + str(last_coordinate[0]) + ") to have direction " + str(room_dir).replace("0", "N").replace("1", "E").replace("2", "S").replace("3", "W"))
			
			
			_grid[last_coordinate[0]][last_coordinate[1]].directions.append(room_dir)
			_grid[current_y][current_x] = Room.new(Room.room_type.END, []) if i == branch_length - 1 else Room.new(Room.room_type.MAIN_BRANCH, [inverse_room_dir])
		else:
			return -1
			
	print("GEN002 | Generating main branch finished. Starting extra paths.")
	
	var dead_end_count: int = 0
	
	current_y = 0
	for row: Array[Room] in _grid:
		current_x = 0
		for room: Room in row:
			if room.type == Room.room_type.MAIN_BRANCH or room.type == Room.room_type.START:
				if randf() <= dead_end_chance and dead_end_count < dead_end_max:
					dead_end_count += 1
					var directions: Array[Array] = get_directions(x_size, y_size, current_x, current_y, _grid)
					
					if directions.size() == 0:
						continue  # Use continue instead of return to skip to the next iteration
					last_coordinate = [current_y, current_x]
					current_coordinate = directions[randi_range(0, directions.size() - 1)]
					current_x = current_coordinate[1]
					current_y = current_coordinate[0]
					
					var dx = current_x - last_coordinate[1]
					var dy = current_y - last_coordinate[0]

					var room_dir: Room.direction
					var inverse_room_dir: Room.direction

					if dy < 0:
						room_dir = Room.direction.NORTH
						inverse_room_dir = Room.direction.SOUTH
					elif dy > 0:
						room_dir = Room.direction.SOUTH
						inverse_room_dir = Room.direction.NORTH
					elif dx < 0:
						room_dir = Room.direction.WEST
						inverse_room_dir = Room.direction.EAST
					elif dx > 0:
						room_dir = Room.direction.EAST
						inverse_room_dir = Room.direction.WEST

					print("GEN003 | (" + str(current_x) + ", " + str(current_y) + ") with direction " + str(inverse_room_dir) + " invoked (" + str(last_coordinate[1]) + ", " + str(last_coordinate[0]) + ") to have direction " + str(room_dir).replace("0", "N").replace("1", "E").replace("2", "S").replace("3", "W"))

					_grid[last_coordinate[0]][last_coordinate[1]].directions.append(room_dir)
					_grid[current_y][current_x] = Room.new(Room.room_type.GENERIC, [inverse_room_dir])
					generation_finished.emit(_grid)
			current_x += 1
		current_y += 1
	return _grid

func get_directions(max_x: int, max_y: int, x: int, y: int, grid: Array[Array]) -> Array[Array]:
	var directions: Array[Array] = []

	# Only set if neighbour is valid
	if y > 0: 
		if grid[y - 1][x].type == Room.room_type.EMPTY:
			directions.append([y - 1, x])
	if y < max_y - 1:
		if grid[y + 1][x].type == Room.room_type.EMPTY:
			directions.append([y + 1, x])
	if x > 0: 
		if grid[y][x - 1].type == Room.room_type.EMPTY:
			directions.append([y, x - 1])
	if x < max_x - 1:
		if grid[y][x + 1].type == Room.room_type.EMPTY:
			directions.append([y, x + 1])

	return directions

func generate():
	var generation_done: bool = false
	# This has to be Variant due to some weird error
	var grid: Variant
	while not generation_done:
		grid = make_grid(x, y)
		grid = generate_dungeon(grid, 5, 0.25, 3)
		if grid is Array[Array]:
			generation_done = true
	print("GEN004 | Room Generation OK")

func _process(delta):
	pass
