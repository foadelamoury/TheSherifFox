class_name ReplaceScene
extends Node

@export var replace_target : Node2D
@export_file() var replacement_scene_path : String


	
func replace():
	var instance : Node2D = load(replacement_scene_path) . instantiate()
	call_deferred("_reposition_and_free", instance)

func _reposition_and_free(p_instance : Node2D):
	replace_target.get_parent().add_child(p_instance)
	p_instance.global_position = replace_target.global_position
	replace_target.queue_free()
