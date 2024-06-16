extends Node2D

# Preload room scenes
@export var ROOM_SCENES: Array[Array]

# This function spawns the dungeon based on the generated array
func spawn_dungeon(dungeon: Array):
	var room_size = Vector2(64, 64)  # Adjust based on your room size

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
			var room_scene = ROOM_SCENES[room.type][dirval].instance()

			room_scene.position = Vector2(x, y) * room_size

			add_child(room_scene)
