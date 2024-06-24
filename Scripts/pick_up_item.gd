extends Node2D


@onready var Item = $Item
@onready var Icon = $Item/Icon
@onready var Outline = $Item/Outline
var pickup = false
@onready var Player = get_tree().get_first_node_in_group("Player")
@onready var Inventory = get_tree().get_first_node_in_group("Inventory")

func _ready():
	var Icon_path = "res://Assets/" + DataHandler.item_data[str(Item.item_ID)]["Name"] + ".png"
	Icon.texture = load(Icon_path)
	Outline.texture = load(Icon_path)
	Outline.visible = false
	#Icon.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	


func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		if not Player.pickup:
			pickup = true
			Outline.visible = true
		
func _on_area_2d_body_exited(body):
	if body.is_in_group("Player"):
		pickup = false
		Outline.visible = false
		
func _unhandled_input(event):
	if event.is_action_released("pickup"):
		for body in $Area2D.get_overlapping_bodies():
			if body.is_in_group("Player"):
				if not Player.pickup:
					pickup = true
					Outline.visible = true
		if pickup and not Player.pickup:
			Player.get_node("collectitem").play()
			Player.pickup = true
			Item.reparent(Inventory)
			Item.load_item(Item.item_ID)    #randomize this for different items to spawn
			Item.scale = Vector2(2,2)
			Item.selected = true
			Inventory.item_held = Item
			#Item.get_child(0).expand_mode = TextureRect.EXPAND_KEEP_SIZE
			if not Inventory.visible:
				Inventory.inv_visible = true
			queue_free()
		
