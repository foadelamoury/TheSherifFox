extends Node2D

@export var speed:int = 5
@export var damage:int = 1
@export var range:int = 200
@onready var og_position = Vector2.ZERO
var bullet_direction = Vector2.ZERO
var og = false
@export var explosion_bullets:PackedScene


func _physics_process(delta):
	if not og:
		og = true
		og_position = global_position
	if bullet_direction != Vector2.ZERO:
		var direction = global_position - og_position
		var velocity = bullet_direction * speed
		global_position += velocity
		if direction.length() >= range:
			explode()
			
func set_direction(var_direction:Vector2):
	bullet_direction = var_direction
	rotation += var_direction.angle()
	

func _on_timer_timeout():
	queue_free()

func explode():
	var explosion_instance = explosion_bullets.instantiate()
	explosion_instance.global_position = global_position
	get_tree().get_root().add_child(explosion_instance)
	queue_free()
	
func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.damaged()
		queue_free()
