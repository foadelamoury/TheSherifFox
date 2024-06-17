extends Node2D

var speed = 7

var position_captured = false
var og_position:Dictionary = {}
func _ready():
	for child in get_children():
		if child is Area2D:
			og_position[child.name] = child.global_position	
func _physics_process(delta):
	for child in get_children():
		if child is Area2D:
			var bullet_direction = (og_position[child.name] - global_position).normalized()
			child.set_direction(bullet_direction)

func _on_timer_timeout():
	for child in get_children():
		if child is Area2D:
			queue_free()
	queue_free()
