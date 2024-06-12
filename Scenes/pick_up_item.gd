extends Node2D


@onready var Item = $Item
@onready var Icon = $Item/Icon
var pickup = false
@onready var Player = get_tree().get_first_node_in_group("Player")
@onready var Inventory = get_tree().get_first_node_in_group("Inventory")
func _ready():
	var Icon_path = "res://Assets/" + DataHandler.item_data[str(Item.item_ID)]["Name"] + ".png"
	Icon.texture = load(Icon_path)
	Icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		pickup = true


func _on_area_2d_body_exited(body):
	if body.is_in_group("Player"):
		pickup = false
func _unhandled_input(event):
	if event.is_action_released("pickup"):
		if pickup:
			Item.reparent(Inventory)
			Item.load_item(Item.item_ID)    #randomize this for different items to spawn
			Item.selected = true
			Inventory.item_held = Item
			Item.get_child(0).expand_mode = TextureRect.EXPAND_KEEP_SIZE
			if not Inventory.visible:
				Inventory.visible = true
			queue_free()
