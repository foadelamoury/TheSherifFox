class_name GrowOverTime
extends Node2D

## Scales the node2D up over time based on a growth curve

signal growing_changed(status : bool)

@export var growth_curve : Curve
@export var duration : float = 1.0

## Start growing as soon as the node is ready
@export var grow_on_ready = true

var time_elapsed = 0.0
var growing = false :
	set(value):
		if(value == growing):
			return

		growing = value
		emit_signal("growing_changed", growing)
func _ready():
	
	if(grow_on_ready):
		start()


func _process(delta):
	time_elapsed += delta
	
	if(growing):
		grow()
	

func start():
	growing = true

func grow():
	var progress = clampf(time_elapsed / duration, 0.0, 1.0)
	
	scale = Vector2(
		growth_curve.sample(progress),
		growth_curve.sample(progress)
	)
	
	if(progress >= 1.0):
		growing = false
