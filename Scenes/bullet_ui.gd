extends Control

@onready var container = $MarginContainer/HBoxContainer
@onready var Player = get_tree().get_first_node_in_group("Player")

func _ready():
	Player.bullet_ui.connect(Callable(self,"change_ui"))
	change_ui()
func change_ui():
	if Player.gun_equipped == null:
		for child in container.get_children():
			child.visible = false
	else:
		for child in container.get_children():
			child.visible = false
		var bullets:Array
		for child in container.get_children():
			bullets.append(child)
		bullets.reverse()
		for i in range(bullets.size()):
			if i <= Player.gun_equipped.rounds-1:
				bullets[i].visible = true
