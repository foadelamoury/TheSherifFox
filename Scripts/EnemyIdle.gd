extends State
class_name EnemyIdle

var move_direction:Vector2
var wander_time: float
@export var enemy:CharacterBody2D
@export var move_speed:float = 30
var waiting = false
var player:CharacterBody2D
var range:float
func randomize_wander():
	move_direction = Vector2(randf_range(-1,1),randf_range(-1,1)).normalized()
	wander_time = randf_range(1,2)
func Enter():
	waiting = false
	randomize_wander()
	player = get_tree().get_first_node_in_group("Player")
	range = enemy.range
func Update(delta: float):
	if wander_time > 0:
		wander_time -= delta
	else:
		waiting = true
		enemy.waitTimer.start()
		randomize_wander()
		
func Physics_Update(delta:float):
	if enemy and range:
		var direction = player.global_position - enemy.global_position
		if direction.length() < (range+500):
			Transitioned.emit(self,"EnemyFollow")
		if waiting:
			enemy.velocity = Vector2(0,0)
		else:
			enemy.velocity = move_direction * move_speed
			
			
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
func _on_wait_timer_timeout():
	waiting = false
