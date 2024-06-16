class_name PlayerUseAbilityComponent
extends Node

@export var use_ability_action_name = "use_ability"
@export var ability : Ability
@export var user : Node2D

func _input(event) :
	if(event.is_action_pressed(use_ability_action_name)):
		ability.use(user)
