extends Node2D

@export var rooms: Array[PackedScene]
@export var tile_size: Vector2i
@export var room_size: Vector2i
var first_room
var room_int = 0
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var worldGen = get_tree().get_first_node_in_group("WorldGen")
@onready var BossTele = get_tree().get_first_node_in_group("Bosstele")

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
				
				if room.type == Room.room_type.START:
					player.position.x = x * room_size.x * tile_size.x
					player.position.y = y * room_size.y * tile_size.y
					BossTele.position.x = x * room_size.x * tile_size.x 
					BossTele.position.y = y * room_size.y * tile_size.y - 150
				
				worldGen.generation_done = true
				room_int += 1
