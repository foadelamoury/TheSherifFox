class_name Projectile
extends Node2D

@export var speed = 100.0

var direction = Vector2.ZERO
var source : Node
var launched = false

func _ready():
	call_deferred("_validate_setup")

func _physics_process(delta):
	position += direction * speed * delta

func launch(p_source : Node, p_direction : Vector2):
	source = p_source
	direction = p_direction
	launched = true


func _validate_setup() -> bool:
	var no_problems = true



	if(launched == false):
		push_warning("Projectile created but launch not called")
		no_problems = false
	return no_problems
