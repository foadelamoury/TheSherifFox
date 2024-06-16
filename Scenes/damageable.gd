class_name Damageable
extends Node

signal on_hit(node : Node, damage_taken : int, knockback_direction : Vector2)
signal health_changed(new_health : float)

@export var health_signal_bus : HealthSignalBus
@export var health : float = 20 :
	get:
		return health
	set(value):
		# Call the global emit signal so responders dont need
		# to connect directly with this object to receive the signal data
		
		var change = value - health
		health = value
		
		if(health_signal_bus != null):
			health_signal_bus.emit_signal("health_changed_by", get_parent(), change)
			
		emit_signal("health_changed", health)
		
@export var dead_animation_name : String = "dead"

func hit(damage : int, knockback_direction : Vector2):
	health -= damage
	
	# Local signal for subscribers that only care about this specific
	# damageable object
	emit_signal("on_hit", get_parent(), damage, knockback_direction)

# After the dead animation plays, remove the parent node from the scene
# This also removes children
func _on_animation_tree_animation_finished(anim_name):
	if(anim_name == dead_animation_name):
		# character is finished dying, remove from the game
		get_parent().queue_free()
