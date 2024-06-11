extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func handle_bullet_spawned(bullet,bullet_position,bullet_direction):
	add_child(bullet)
	bullet.global_position = bullet_position
	bullet.set_direction(bullet_direction)
