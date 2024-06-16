extends Node

@export var grow_over_time : GrowOverTime
@export var queue_free_target : Node

func _ready():
	grow_over_time.connect("growing_changed", _on_growing_changed)

func _on_growing_changed(p_status : bool):
	if(p_status == false):
		queue_free_target.queue_free()
