extends Area2D

@export var speed:int = 20
@export var damage:int = 1
var bullet_direction = Vector2.ZERO
var AnimPlayer:AnimationPlayer


func _ready():
	AnimPlayer = find_child("AnimationPlayer")
	if AnimPlayer:
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


func _on_body_entered(body):
	if body.is_in_group("Enemy"):
		body.health -= damage
		queue_free()
