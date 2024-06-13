extends CharacterBody2D

signal player_fired_bullet(Bullet,bullet_position,bullet_direction)

@onready var weapon_pivot = $WeaponPivot
@export var gun_equipped:Weapon
@onready var weapon_sprite = $WeaponPivot/GunSprite
@onready var EndOfGun = $WeaponPivot/GunSprite/EndOfGun
@onready var GunDirection = $WeaponPivot/GunSprite/GunDirection

@export var movement_speed = 300.0
@export var direction_speed = 1.2
@onready var Inventory = get_tree().get_first_node_in_group("Inventory")
var weapons_path = "res://Data/Weapons/"
var weapons_folder = DirAccess.open(weapons_path)
var weapon_wheel:int = 0
var flipped = false
# TODO: Please make an @onready reference to the Animation Player to be consistent in the coding style
# TODO: Please be typesafe with function return types not inherited from base class (e.g. shoot())
func _ready():
	if gun_equipped != null:
		change_gun()
func _physics_process(delta):
	
	var mouse_direction: Vector2 = (get_global_mouse_position() - global_position).normalized()
	
	var direction: Vector2 = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	
	if direction:
		velocity = direction * movement_speed
		$AnimationPlayer.play("RUN")
	else:
		velocity.x = move_toward(velocity.x,0,movement_speed)
		velocity.y = move_toward(velocity.y,0,movement_speed)
	if velocity == Vector2.ZERO:
		$AnimationPlayer.play("IDLE")
	if mouse_direction.x > 0 and $Sprite2D.flip_h:
		flipped = false
		$Sprite2D.flip_h = false
		if weapon_sprite.scale.y < 0:
			weapon_sprite.scale.y = -weapon_sprite.scale.y
	elif mouse_direction.x < 0 and !$Sprite2D.flip_h:
		flipped = true
		$Sprite2D.flip_h = true
		if weapon_sprite.scale.y > 0:
			weapon_sprite.scale.y = -weapon_sprite.scale.y
	move_and_slide()
	weapon_pivot.look_at(get_global_mouse_position())
	
func _unhandled_input(event):
	if event.is_action_released("shoot"):
		shoot()
	if event.is_action_released("switch_guns"):
		switch_guns()
func shoot() -> void:
	if gun_equipped !=null:
		var bullet = gun_equipped.bullet_type
		var bullet_instance = bullet.instantiate()
		var bullet_position = EndOfGun.global_position
		var bullet_direction = (GunDirection.global_position - EndOfGun.global_position).normalized()
		player_fired_bullet.emit(bullet_instance,bullet_position,bullet_direction)

func change_gun():
	if gun_equipped !=null:
		var weapon_icon = gun_equipped.icon
		weapon_sprite.texture = weapon_icon
		EndOfGun.global_position = weapon_sprite.global_position
		GunDirection.global_position = EndOfGun.global_position
		if not flipped:
			EndOfGun.global_position.x += weapon_sprite.texture.get_width()
			GunDirection.global_position = EndOfGun.global_position
			GunDirection.global_position.x += 5
		else:
			EndOfGun.global_position.x -= weapon_sprite.texture.get_width()
			GunDirection.global_position = EndOfGun.global_position
			GunDirection.global_position.x -= 5
func switch_guns():
	var items:Array = Inventory.items
	var guns_equipped:Array
	weapons_folder.list_dir_begin()
	var all_weapons:Array
	while true:
		var temp_weapon = weapons_folder.get_next()
		if temp_weapon == "":
			break
		all_weapons.append(temp_weapon)
	for z in range(all_weapons.size()):
		for i in range(items.size()):
			var temp_weapon = load(weapons_path+all_weapons[z])
			if items[i].item_ID == temp_weapon.item_ID:
				guns_equipped.append(temp_weapon)
	if guns_equipped.is_empty():
		return
	gun_equipped = guns_equipped[weapon_wheel]
	change_gun()
	weapon_wheel+=1
	if weapon_wheel > (guns_equipped.size()-1):
		weapon_wheel = 0
