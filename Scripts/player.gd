extends CharacterBody2D

signal player_fired_bullet(Bullet,bullet_position,bullet_direction)
signal bullet_ui()
@onready var weapon_pivot = $WeaponPivot
@export var gun_equipped:Weapon:
	set(value):
		gun_equipped = value
		bullet_ui.emit()
@onready var weapon_sprite = $WeaponPivot/GunSprite
@onready var EndOfGun = $WeaponPivot/GunSprite/EndOfGun
@onready var GunDirection = $WeaponPivot/GunSprite/GunDirection
@onready var shootTimer = $ShootTimer
@onready var reloadTimer = $ReloadTimer
@export var movement_speed = 300.0
@export var direction_speed = 1.2
@onready var Inventory = get_tree().get_first_node_in_group("Inventory")
@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D
var weapons_path = "res://Data/Weapons/"
var weapons_folder = DirAccess.open(weapons_path)
var weapon_wheel:int = 0
var flipped = false
var shooting = false
var reloading = false

func _ready():
	bullet_ui.emit()
	if gun_equipped != null:
		change_gun()

func _physics_process(delta):
	
	var mouse_direction: Vector2 = (get_global_mouse_position() - global_position).normalized()
	
	var direction: Vector2 = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	
	if direction:
		velocity = direction * movement_speed
		animation_player.play("RUN")
	else:
		velocity.x = move_toward(velocity.x,0,movement_speed)
		velocity.y = move_toward(velocity.y,0,movement_speed)
	if velocity == Vector2.ZERO:
		animation_player.play("IDLE")
	if mouse_direction.x > 0 and sprite_2d.flip_h:
		flipped = false
		sprite_2d.flip_h = false
		if weapon_sprite.scale.y < 0:
			weapon_sprite.scale.y = -weapon_sprite.scale.y
	elif mouse_direction.x < 0 and !sprite_2d.flip_h:
		flipped = true
		sprite_2d.flip_h = true
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
		if not shooting and not reloading and gun_equipped.rounds>=1:
			shooting = true
			shootTimer.start()
			var bullet = gun_equipped.bullet_type
			var bullet_instance = bullet.instantiate()
			var bullet_position = EndOfGun.global_position
			var bullet_direction = (GunDirection.global_position - EndOfGun.global_position).normalized()
			player_fired_bullet.emit(bullet_instance,bullet_position,bullet_direction)
			gun_equipped.rounds -=1
			bullet_ui.emit()
			if gun_equipped.rounds ==0:
				reload()
func change_gun() -> void:
	if gun_equipped !=null:
		bullet_ui.emit()
		shootTimer.wait_time = gun_equipped.shooting_speed
		reloadTimer.wait_time = gun_equipped.reload_speed
		var weapon_icon = gun_equipped.icon
		weapon_sprite.texture = weapon_icon
		weapon_pivot.rotation = 0
		EndOfGun.global_position = weapon_sprite.global_position
		GunDirection.global_position = EndOfGun.global_position
		EndOfGun.global_position.x += 10
		GunDirection.global_position = EndOfGun.global_position
		GunDirection.global_position.x += 5
	else:
		weapon_sprite.texture = null
		
func switch_guns() -> void:
	var items:Array = Inventory.items
	var guns_equipped:Array
	for i in range(items.size()):
		guns_equipped.append(items[i])
	if guns_equipped.is_empty():
		return
	gun_equipped = guns_equipped[weapon_wheel]
	change_gun()
	weapon_wheel+=1
	if weapon_wheel > (guns_equipped.size()-1):
		weapon_wheel = 0

func reload() -> void:
	reloading = true
	reloadTimer.start()
	
func check_gun() -> void:
	if gun_equipped == null:
		return
	var items:Array = Inventory.items
	var guns_equipped:Array
	weapons_folder.list_dir_begin()
	var all_weapons:Array
	for i in range(items.size()):
		guns_equipped.append(items[i])
	if guns_equipped.is_empty():
		print("!!!")
	var is_player_gun_in_inventory = false
	for i in range(guns_equipped.size()):
		if guns_equipped[i].name == gun_equipped.name:
			is_player_gun_in_inventory = false
	if not is_player_gun_in_inventory:
		gun_equipped = null
		change_gun()
	
func _on_shoot_timer_timeout():
	shooting = false

func _on_reload_timer_timeout():
	reloading = false
	if gun_equipped!= null:
		gun_equipped.rounds = gun_equipped.clip_size
		bullet_ui.emit()
