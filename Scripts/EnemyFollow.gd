extends State
class_name EnemyFollow

@export var enemy:CharacterBody2D
@export var move_speed:float = 50

var player:CharacterBody2D
var range:float
func Enter():
	player = get_tree().get_first_node_in_group("Player")
	range = enemy.range
func Update(delta: float):
	pass
		
func Physics_Update(delta:float):
	var direction = player.global_position - enemy.global_position
	
	if direction.length() > range:
		if direction.length() > (range + 200):
			Transitioned.emit(self,"EnemyIdle")
		else:
			enemy.velocity = direction.normalized() * move_speed
			if enemy.velocity.x <0:
				enemy.sprite_2d.flip_h = true
			if enemy.velocity.x <0:
				enemy.sprite_2d.flip_h = true
				enemy.weapon_pivot.rotation_degrees = -180
				if enemy.weapon_sprite.scale.y > 0:
					enemy.weapon_sprite.scale.y = -enemy.weapon_sprite.scale.y
			else:
				enemy.sprite_2d.flip_h = false
				enemy.weapon_pivot.rotation_degrees = 0
				if enemy.weapon_sprite.scale.y < 0:
					enemy.weapon_sprite.scale.y = -enemy.weapon_sprite.scale.y
	else:
		Transitioned.emit(self,"EnemyAim")

