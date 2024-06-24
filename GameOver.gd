extends Node2D


func _on_play_again_button_down():
	get_tree().change_scene_to_file("res://Scenes/world_generation.tscn")
