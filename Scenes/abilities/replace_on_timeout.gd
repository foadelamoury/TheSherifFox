class_name ReplaceOnTimeout
extends ReplaceScene

@export var replace_timer : Timer

func _ready():
	replace_timer. connect("timeout", _on_timeout)

func _on_timeout():
	replace()
