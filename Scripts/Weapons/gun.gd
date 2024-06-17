extends Node2D
class_name Gun

@export var bullet: PackedScene
@export var bullet_count: int = 1
@export_range(8, 368) var arc: float = 0
@export_range(0, 20) var fire_rate: float = 2.8

var can_shoot = true

func shoot():
	if can_shoot:
		can_shoot = false
		for i in bullet_count:
			var new_bullet = bullet.instantiate()
			new_bullet.position = global_position
			var arc_rad = deg_to_rad(arc)
			var increment = arc_rad / (bullet_count - 1)
			new_bullet.global_rotation = (
				global_rotation +
				increment * i -
				arc_rad / 2
			)
			get_tree().root.call_deferred("add_child", new_bullet)
		await get_tree().create_timer(1 / fire_rate).timeout
		can_shoot = true
