extends Node2D

@export var enemy_bullet:PackedScene
@export var speed:float = 5
@export var rotating_speed:float = 5
@export var spawn_point_count:int = 4
@export var radius:int = 100
@export var shoot_time:float = 0.2
@onready var ShootTimer = $ShootTimer
@onready var rotater = $Rotater
func _ready():
	var step = 2* PI / spawn_point_count
	for i in range(spawn_point_count):
		var spawn_point = Node2D.new()
		var pos = Vector2(radius,0).rotated(step*i)
		spawn_point.position = pos
		spawn_point.rotation = pos.angle()
		rotater.add_child(spawn_point)
	ShootTimer.wait_time = shoot_time
	ShootTimer.start()
	
func _process(delta):
	var new_rotation = rotater.rotation_degrees + rotating_speed * delta
	rotater.rotation_degrees = fmod(new_rotation,360)
func _on_shoot_timer_timeout():
	for s in rotater.get_children():
		var bullet = enemy_bullet.instantiate()
		get_tree().get_root().add_child(bullet)
		bullet.position = s.global_position
		bullet.rotation = s.global_rotation
		var direction = (s.global_position - global_position).normalized()
		bullet.set_direction(direction)
