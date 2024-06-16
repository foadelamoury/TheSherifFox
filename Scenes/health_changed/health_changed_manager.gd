class_name HealthChangedDisplay
extends Control

@export var health_signal_bus : HealthSignalBus
@export var health_changed_label : PackedScene
@export var damage_color : Color = Color.DARK_RED
@export var heal_color : Color = Color.DARK_GREEN

# Called when the node enters the scene tree for the first time.
func _ready():
	health_signal_bus.connect("health_changed_by", on_signal_health_changed_by)

func on_signal_health_changed_by(p_changed_node : Node, p_amount_changed : int):
	if(p_changed_node != null):
		var label_instance : Label = health_changed_label.instantiate()
		p_changed_node.add_child(label_instance)
		label_instance.text = str(p_amount_changed)
		
		if(p_amount_changed >= 0):
			label_instance.modulate = heal_color
		else:
			label_instance.modulate = damage_color
