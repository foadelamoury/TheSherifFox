extends Node2D

@export var speed = 4

var position_captured = false
@onready var og_position: = global_position
var bullet_direction = Vector2.ZERO
@onready var path:Path2D = $Path2D

func _ready():
	for child in get_children():
		if child is Area2D:
			child.speed = speed	
			
func _physics_process(delta):
	if bullet_direction != Vector2.ZERO:
		var velocity = bullet_direction * speed
		global_position += velocity
		for child:PathFollow2D in path.get_children():
			child.progress_ratio +=delta
func set_direction(var_direction:Vector2):
	bullet_direction = var_direction
	rotation += var_direction.angle()
	

func _on_timer_timeout():
	for child in get_children():
		if child is Area2D:
			queue_free()
	queue_free()
