class_name ProjectileLaunchAbility
extends Ability

@export var projectile_scene : PackedScene
@export var instancing_offset : Vector2

## Tries to use the ability and returns
## whether it was successful or not
func use(p_user : Node2D) -> bool:
	var instance : Projectile = projectile_scene.instantiate()
	p_user.get_parent().add_child(instance)
	var facing_sign = signf(p_user.direction.x)
	var final_offset = Vector2(
	instancing_offset.x * facing_sign,
	instancing_offset.y
	)
	var instance_position = p_user.global_position + final_offset
	instance.global_position = instance_position
	instance.launch(p_user,p_user.direction)

	return true
