extends Control

@onready var slot_scene = preload("res://Scenes/slot.tscn")
@onready var grid_container = $Background/MarginContainer/VBoxContainer/ScrollContainer/GridContainer
@onready var item_scene = preload("res://Scenes/item.tscn")
@onready var scroll_container = $Background/MarginContainer/VBoxContainer/ScrollContainer
@onready var col_count = grid_container.columns #save column number
@onready var grid_container2 = $Background2/MarginContainer/VBoxContainer/ScrollContainer/GridContainer
@onready var PickUpItem = preload("res://Scenes/pick_up_item.tscn")
@onready var Player = get_tree().get_first_node_in_group("Player")
var items:Array
var grid_array := []
var item_held = null
var current_slot = null
var can_place := false
var icon_anchor : Vector2
enum States {DEFAULT, TAKEN, FREE}
var state = States.DEFAULT
var dragging = false
var drag_preview = false
# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(20):
		create_slot()
	for i in range(20):
		if i>=10:
			grid_container.get_child(i).accessible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if item_held:
		if Input.is_action_just_pressed("mouse_rightclick"):
			rotate_item()
		if Input.is_action_just_pressed("mouse_leftclick"):
			if scroll_container.get_global_rect().has_point(get_global_mouse_position()):
				place_item()
			else:
				place_pickup()
	else:
		if Input.is_action_just_pressed("mouse_leftclick"):
			if scroll_container.get_global_rect().has_point(get_global_mouse_position()):
				pick_item()	
	if drag_preview:
		var preview = $Background.get_child(1)
		preview.global_position = get_global_mouse_position()
		if not preview.visible:
			preview.visible = true
			
func create_slot():
	var new_slot = slot_scene.instantiate()
	new_slot.slot_ID = grid_array.size()
	grid_container.add_child(new_slot)
	grid_array.push_back(new_slot)
	new_slot.slot_clicked.connect(slot_clicked)
	new_slot.slot_entered.connect(_on_slot_mouse_entered)
	new_slot.slot_exited.connect(_on_slot_mouse_exited)


func _on_slot_mouse_entered(a_Slot):
	icon_anchor = Vector2(10000,100000)
	current_slot = a_Slot
	if item_held:
		check_slot_availability(current_slot)
		set_grids.call_deferred(current_slot)
	
func _on_slot_mouse_exited(a_Slot):
	clear_grid()
	
	if not grid_container.get_global_rect().has_point(get_global_mouse_position()):
		current_slot = null
func slot_clicked(a_Slot):
	if not dragging:
		if a_Slot.accessible:
			var preview_texture = TextureRect.new()
			preview_texture.texture = a_Slot.texture
			preview_texture.expand_mode = 2
			preview_texture.size = Vector2(60,60)
			var preview = Control.new()
			preview.name = "preview"
			a_Slot.accessible = false
			preview.visible = false
			preview.add_child(preview_texture)
			$Background.add_child(preview)
			drag_preview = true
			dragging = true
	else:
		if not a_Slot.accessible:
			var preview = $Background.get_child(1)
			a_Slot.filter.color = Color("#261515")
			#a_Slot.texture = preview.texture
			a_Slot.accessible = true
			preview.queue_free()
			drag_preview = false
			dragging = false
func _on_button_spawn_pressed():
	var new_item = item_scene.instantiate()
	add_child(new_item)
	new_item.load_item(randi_range(1,4))    #randomize this for different items to spawn
	new_item.selected = true
	item_held = new_item
	
	
func check_slot_availability(a_Slot):
	for grid in item_held.item_grids:
		var grid_to_check = a_Slot.slot_ID + grid[0] + grid[1] * col_count
		var line_switch_check = a_Slot.slot_ID % col_count + grid[0]
		if line_switch_check < 0 or line_switch_check >= col_count:
			can_place = false
			return
		if grid_to_check < 0 or grid_to_check >= grid_array.size():
			can_place = false
			return
		if grid_array[grid_to_check].state == grid_array[grid_to_check].States.TAKEN:
			can_place = false
			return
		
	can_place = true
	
func set_grids(a_Slot):
	for grid in item_held.item_grids:
		var grid_to_check = a_Slot.slot_ID + grid[0] + grid[1] * col_count
		if grid_to_check < 0 or grid_to_check >= grid_array.size():
			continue
		#make sure the check don't wrap around boarders
		var line_switch_check = a_Slot.slot_ID % col_count + grid[0]
		if line_switch_check <0 or line_switch_check >= col_count:
			continue
		
		if can_place:
			grid_array[grid_to_check].set_color(grid_array[grid_to_check].States.FREE)
			#save anchor for snapping
			if grid[1] < icon_anchor.x: icon_anchor.x = grid[1]
			if grid[0] < icon_anchor.y: icon_anchor.y = grid[0]
				
		#else:
			#if a_Slot.accessible:
				#grid_array[grid_to_check].set_color(grid_array[grid_to_check].States.TAKEN)

func clear_grid():
	for grid in grid_array:
		grid.set_color(grid.States.DEFAULT)
	for slot in grid_container.get_children():
		if slot.is_in_group("Slot"):
			if slot.accessible:
				slot.filter.color = Color("#ff000000")
			else:
				slot.filter.color = Color("#261515")
func rotate_item():
	item_held.rotate_item()
	clear_grid()
	if current_slot:
		_on_slot_mouse_entered(current_slot)

func place_item():
	if not can_place or not current_slot: 
		return #put indication of placement failed, sound or visual here
		
	#for changing scene tree
	item_held.get_parent().remove_child(item_held)
	grid_container.add_child(item_held)
	item_held.global_position = get_global_mouse_position()
	####
	var calculated_grid_id = current_slot.slot_ID + icon_anchor.x * col_count + icon_anchor.y
	item_held._snap_to(grid_array[calculated_grid_id].global_position)

	item_held.grid_anchor = current_slot
	for grid in item_held.item_grids:
		var grid_to_check = current_slot.slot_ID + grid[0] + grid[1] * col_count
		grid_array[grid_to_check].state = grid_array[grid_to_check].States.TAKEN 
		grid_array[grid_to_check].item_stored = item_held
		
	var weapons_path = "res://Data/Weapons/"
	var weapons_folder = DirAccess.open(weapons_path)
	weapons_folder.list_dir_begin()
	var all_weapons:Array
	while true:
		var temp_weapon = weapons_folder.get_next()
		if temp_weapon == "":
			break
		all_weapons.append(temp_weapon)
	for z in range(all_weapons.size()):
		var temp_weapon = load(weapons_path+all_weapons[z])
		if item_held.item_ID == temp_weapon.item_ID:
			item_held = temp_weapon.duplicate()
	items.append(item_held)
	item_held = null
	clear_grid()
	
func pick_item():
	if dragging:
		return
	if not current_slot or not current_slot.item_stored: 
		return
	item_held = current_slot.item_stored
	item_held.selected = true
	#move node in the scene tree
	item_held.get_parent().remove_child(item_held)
	add_child(item_held)
	item_held.global_position = get_global_mouse_position()
	####
	
	for grid in item_held.item_grids:
		var grid_to_check = item_held.grid_anchor.slot_ID + grid[0] + grid[1] * col_count # use grid anchor instead of current slot to prevent bug
		grid_array[grid_to_check].state = grid_array[grid_to_check].States.FREE 
		grid_array[grid_to_check].item_stored = null
	
	check_slot_availability(current_slot)
	set_grids.call_deferred(current_slot)
	
func place_pickup():
	var new_pickup = PickUpItem.instantiate()
	var item = new_pickup.get_child(0)
	item.item_ID = item_held.item_ID
	var icon:TextureRect = new_pickup.get_child(0).get_child(0)
	get_tree().get_root().add_child(new_pickup)
	#icon.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	new_pickup.global_position =  get_global_mouse_position()
	item_held.get_parent().remove_child(item_held)
	items.erase(item_held)
	item_held = null
	Player.check_gun()
func pickup_at_player():
	var new_pickup = PickUpItem.instantiate()
	#new_pickup.get_child(0).load_item(item_held.item_ID)
	var item = new_pickup.get_child(0)
	var icon:TextureRect = new_pickup.get_child(0).get_child(0)
	item.item_ID = item_held.item_ID
	#icon.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	get_tree().get_root().add_child(new_pickup)
	new_pickup.global_position =  Player.global_position+ Vector2(randf_range(0,3),randf_range(0,3))
	item_held.get_parent().remove_child(item_held)
	items.erase(item_held)
	for grid in item_held.item_grids:
		var grid_to_check = item_held.grid_anchor.slot_ID + grid[0] + grid[1] * col_count # use grid anchor instead of current slot to prevent bug
		grid_array[grid_to_check].state = grid_array[grid_to_check].States.TAKEN
		grid_array[grid_to_check].item_stored = null
	item_held = null
	Player.check_gun()	
func _on_add_slot_pressed():
	#create_slot()
	remove_slot()
func _unhandled_input(event):
	if event.is_action_released("ui_focus_next"):
		if visible:
			visible = false
			get_tree().paused = false
		else:
			visible = true
			get_tree().paused = true
func add_slot():
	var slots:Array
	for child in grid_container.get_children():
		if child.is_in_group("Slot") and not child.accessible:
			slots.append(child)
	slots[0].accessible = true
func remove_slot():
	var slots:Array
	for child in grid_container.get_children():
		if child.is_in_group("Slot") and child.accessible:
			slots.append(child)
	slots[-1].accessible = false
	current_slot = slots[-1]
	if current_slot.item_stored:
		item_held = current_slot.item_stored
		current_slot.item_stored = null
		pickup_at_player()
