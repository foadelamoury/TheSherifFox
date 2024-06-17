extends State
class_name EnemyAim

@export var enemy:CharacterBody2D
var rotation_speed = 10
var player:CharacterBody2D
var range:float
var angle_to_player

func Enter():
		player = get_tree().get_first_node_in_group("Player")
		range = enemy.range
func Update(delta: float):
	pass
func Physics_Update(delta:float):
	if enemy and range:
		enemy.velocity = Vector2(0,0)
		var direction = player.global_position - enemy.global_position
		angle_to_player = enemy.global_position.direction_to(player.global_position).angle()
		enemy.weapon_pivot.rotation = angle_to_player
		if enemy.weapon_pivot.rotation < -1.5 or enemy.weapon_pivot.rotation > 1.5:
			enemy.sprite_2d.flip_h = true
			if enemy.weapon_sprite.scale.y > 0:
				enemy.weapon_sprite.scale.y = -enemy.weapon_sprite.scale.y
		else:
			enemy.sprite_2d.flip_h = false
			if enemy.weapon_sprite.scale.y < 0:
				enemy.weapon_sprite.scale.y = -enemy.weapon_sprite.scale.y
		#shoot
		if enemy.shootTimer.is_stopped() and enemy.reloadTimer.is_stopped() and enemy.waitTimer.is_stopped():
			enemy.shootTimer.start()
		if direction.length() > (range+300):
			Transitioned.emit(self,"EnemyFollow")

func _on_shoot_timer_timeout():
	if enemy.weapon_equipped:
		if enemy.find_child("StateMachine").current_state.name == name:
			enemy.shootTimer.wait_time = randf_range(enemy.shooting_speed-0.5,enemy.shooting_speed)
			#enemy.weapon_pivot.rotation = randf_range(enemy.weapon_pivot.rotation-enemy.accuracy,enemy.weapon_pivot.rotation+enemy.accuracy)
			var bullet = enemy.weapon_equipped.bullet_type
			var bullet_instance = bullet.instantiate()
			var bullet_position = enemy.EndOfGun.global_position
			var bullet_direction = (enemy.GunDirection.global_position - enemy.EndOfGun.global_position).normalized()
			get_tree().get_root().add_child(bullet_instance)
			bullet_instance.global_position = bullet_position
			bullet_instance.set_direction(bullet_direction)
			enemy.weapon_equipped.rounds -= 1
			if enemy.weapon_equipped.rounds == 0:
				enemy.reloadTimer.start()
				#play reload animation
			enemy.waitTimer.start()
func _on_reload_timer_timeout():
	enemy.weapon_equipped.rounds = enemy.weapon_equipped.clip_size
