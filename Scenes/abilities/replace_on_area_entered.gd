class_name ReplaceOnAreaEntered
extends ReplaceScene

@export var enter_area : Area2D

func _ready():
	enter_area.connect("body_entered", _on_body_entered)

func _on_body_entered(_p_body : Node2D):
	replace()


