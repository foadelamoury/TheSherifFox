extends Node

@export var rooms: Array[PackedScene]

var x: int = 4
var y: int = 4

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
				color = Color(255, 255, 255)
			elif cell.type == Room.room_type.START:
				color = Color(255, 0, 0)
			elif cell.type == Room.room_type.END:
				color = Color(0, 255, 0)
			elif cell.type == Room.room_type.GENERIC:
				color = Color(0, 0, 0)
			img.set_pixel(cellnum, rownum, color)
			cellnum += 1
		rownum += 1
	img.save_png("C:/Users/Fabian/Desktop/gen/dungeon" + str(Time.get_ticks_usec()) + ".png")

func make_grid(sizeX: int, sizeY: int) -> Array[Array]:
	var grid: Array[Array] = []
	for i in range(sizeX):
		var row: Array = []
		for j in range(sizeY):
			row.append(Room.new(Room.room_type.EMPTY, []))
		grid.append(row)
	return grid

func generate_dungeon(grid: Array[Array], branch_length: int, dead_end_chance: float, dead_end_max: int) -> Array[Array]:
	var _grid: Array[Array] = grid
	var x_size: int = _grid[0].size()
	var y_size: int = _grid.size()

	var last_coordinate: Array[int] = [0, 0]
	var current_coordinate: Array[int] = [floor(float(y_size) / 2.0), 0]
	var current_x: int = current_coordinate[1]
	var current_y: int = current_coordinate[0]

	# Generate starting room
	_grid[current_y][current_x] = Room.new(Room.room_type.START, [])

	for i in range(branch_length):
		# Get neighbours
		var north: Array[int] = [0, 0]
		var east: Array[int] = [0, 0]
		var south: Array[int] = [0, 0]
		var west: Array[int] = [0, 0]

		var dir_states: Array[Room.direction] = []

		# Only set if neighbour is valid
		if current_y != 0:
			north = [current_y - 1, current_x]
			dir_states.append(Room.direction.NORTH)
		if current_y != y_size - 1:
			south = [current_y + 1, current_x]
			dir_states.append(Room.direction.SOUTH)
		if current_x != x_size - 1:
			east = [current_y, current_x + 1]
			dir_states.append(Room.direction.EAST)
		if current_x != 0:
			west = [current_y, current_x - 1]
			dir_states.append(Room.direction.WEST)

		var directions: Array = []

		# Check valid directions
		for dir in [north, south, east, west]:
			if dir != [0, 0] and _grid[dir[0]][dir[1]].type == Room.room_type.EMPTY:
				directions.append(dir)

		# Set room
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
			_grid[current_y][current_x] = Room.new(Room.room_type.END, []) if i == branch_length - 1 else Room.new(Room.room_type.GENERIC, [inverse_room_dir])
		else:
			push_error("GEN401 | Room has no valid directions.")

	return _grid

func _ready():
	var grid: Array[Array] = make_grid(x, y)
	grid = generate_dungeon(grid, 5, 0.0, 0)
	render_dungeon(grid)

func _process(delta):
	pass
