extends Node2D

@export var rooms: Array[PackedScene]
@export var tile_size: Vector2i
@export var room_size: Vector2i

func spawn_dungeon(dungeon: Array):
	
	for child in get_children():
		child.queue_free()
	
	for y in range(dungeon.size()):
		for x in range(dungeon[y].size()):
			var room: Room = dungeon[y][x]
			
			var dirval = 0
			for direction in room.directions:
				if direction == Room.direction.NORTH:
					dirval += 1
				if direction == Room.direction.EAST:
					dirval += 2
				if direction == Room.direction.SOUTH:
					dirval += 4
				if direction == Room.direction.WEST:
					dirval += 8
			
			# The direction value is stored in a bitwise binary format
			# This means: N = 1, E = 2, NE = ..., S, SN, SE, SEN, W, WN, WE, WEN, WS, WSN, WSE = ..., WSEN = 15
			# Yes, we have to make each room by hand 15 times
			
			if room.type != Room.room_type.EMPTY:
				#var room_scene = load(rooms[dirval + room.type * 16].resource_path).instantiate()
				var room_scene = load(rooms[dirval].resource_path).instantiate()
				room_scene.position = Vector2i(x, y) * room_size * tile_size
				add_child(room_scene)
