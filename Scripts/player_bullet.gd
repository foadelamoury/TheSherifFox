extends Area2D

@export var speed:int = 20

var bullet_direction = Vector2.ZERO
@onready var AnimPlayer = $AnimationPlayer
func _ready():
	AnimPlayer.speed_scale = 3
	AnimPlayer.play("fly")
func _physics_process(delta):
	if bullet_direction != Vector2.ZERO:
		var velocity = bullet_direction * speed
		global_position += velocity
		
func set_direction(var_direction:Vector2):
	bullet_direction = var_direction
	rotation += var_direction.angle()


func _on_timer_timeout():
	queue_free()
