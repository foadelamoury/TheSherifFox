class_name Room

enum room_type {
	EMPTY,
	START,
	END,
	GENERIC,
	MAIN_BRANCH
}

enum direction {
	NORTH,
	EAST,
	SOUTH,
	WEST
}

var type: room_type
var directions: Array[direction]

func _init(type: room_type, directions: Array[direction]):
	self.type = type
	self.directions = directions

func _to_string() -> String:
	var str = "Room (" + str(self.type) + ") facing "
	if self.directions:
		for dir in self.directions:
			str += str(dir)
	else:
		str += "none"
	return str
