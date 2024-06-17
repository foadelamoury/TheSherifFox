extends Node2D

@export var speed = 7

var position_captured = false
@onready var og_position: = global_position
var bullet_direction = Vector2.ZERO
func _ready():
	for child in get_children():
		if child is Area2D:
			child.speed = speed	
func _physics_process(delta):
	for child in get_children():
		if child is Area2D:
			child.set_direction(bullet_direction)

func set_direction(var_direction:Vector2):
	bullet_direction = var_direction
	rotation += var_direction.angle()
	

func _on_timer_timeout():
	for child in get_children():
		if child is Area2D:
			queue_free()
	queue_free()
