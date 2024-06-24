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
@onready var Inventory = find_child("CanvasLayer").find_child("Inventory")
@onready var sprite_2d = $AnimatedSprite2D
var weapons_path = "res://Data/Weapons/"
var weapons_folder = DirAccess.open(weapons_path)
var weapon_wheel:int = 0
var shooting = false
var reloading = false
var pickup = false
var Hp = 20

func _ready():
	DataHandler.CameraShake = false
	if DataHandler.bosspos == null:
		$AnimatedSprite2D.modulate = Color("ffffff")
	else:
		$AnimatedSprite2D.modulate = Color("828fba")
	Inventory.items = DataHandler.Inventoryitems 
	bullet_ui.emit()
	change_gun()

func _process(delta):
	if Hp <= 0:
		get_tree().change_scene_to_file("res://game_over.tscn")
	
	if DataHandler.CameraShake == true:
		$Camera2D.offset = Vector2(randi_range(1, 5), randi_range(1,5))
	else:
		$Camera2D.offset = Vector2(0, 0)

func _physics_process(delta):
	
	if DataHandler.bosspos != null:
		$BossHealthBar.global_position = Vector2(DataHandler.bosspos.x - 66,DataHandler.bosspos.y - 126) 
		$Camera2D.global_position = DataHandler.bosspos
	else:
		$Camera2D.global_position = global_position
		$Camera2D.offset = Vector2(0, 0)
	
	#if DataHandler.cutscene == true:
		#$Camera2D.enabled = false
	#else:
		#$Camera2D.enabled = true
	
	var mouse_direction: Vector2 = (get_global_mouse_position() - global_position).normalized()
	
	var direction: Vector2 = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	
	if direction:
		velocity = direction * movement_speed
		if direction.x:
			if direction.x > 0:
				sprite_2d.flip_h = false
			else:
				sprite_2d.flip_h = true
			sprite_2d.play("walkSide")
		elif direction.y:
			if direction.y > 0:
				sprite_2d.play("walkSouth")
			else:
				sprite_2d.play("walkNorth")
	else:
		velocity.x = move_toward(velocity.x,0,movement_speed)
		velocity.y = move_toward(velocity.y,0,movement_speed)
	if velocity == Vector2.ZERO:
		sprite_2d.play("idle")
		if $IdleSound.playing:
			$IdleSound.volume_db = -10
	else:
		if not $IdleSound.playing:
			$IdleTimer.start()
		else:
			$IdleSound.volume_db = -15
			
	if mouse_direction.x > 0:
		if weapon_sprite.scale.y < 0:
			weapon_sprite.scale.y = -weapon_sprite.scale.y
	elif mouse_direction.x < 0 and !sprite_2d.flip_h:
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
			
			if gun_equipped.item_ID == 1:
				$ShootBow.play()

func change_gun() -> void:
	#Item IDs
		#1 = How
			#2 = staff
				#5 Revolver
					#6 Rifle
	if gun_equipped:
		bullet_ui.emit()
		shootTimer.wait_time = gun_equipped.shooting_speed
		reloadTimer.wait_time = gun_equipped.reload_speed
		var weapon_icon = gun_equipped.icon
		weapon_sprite.texture = weapon_icon
		if gun_equipped.item_ID == 1:
			$EquipBow.play()
			weapon_sprite.scale = Vector2(1.3, 1.3)
		else:
			weapon_sprite.scale = Vector2(0.5, 0.5)
		weapon_pivot.rotation = 0
		EndOfGun.global_position = weapon_sprite.global_position
		GunDirection.global_position = EndOfGun.global_position
		EndOfGun.global_position.x += 10
		GunDirection.global_position = EndOfGun.global_position
		GunDirection.global_position.x += 5
	else:
		weapon_sprite.texture = null
		
func switch_guns() -> void:
	#Item IDs
	#1 = How
	#2 = staff
	#5 Revolver
	#6 Rifle
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
	if gun_equipped.item_ID == 1:
		$EquipBow.play()

func _on_reload_timer_timeout():
	reloading = false
	if gun_equipped!= null:
		gun_equipped.rounds = gun_equipped.clip_size
		bullet_ui.emit()

func damaged(value):
	Hp -= value



func _on_boss_tele_area_entered(area):
	if area.is_in_group("Player"):
		if DataHandler.EnemyLeft <= 0:
			DataHandler.gunequipped = gun_equipped
			DataHandler.Inventoryitems = Inventory.items
			DataHandler.cutscene = true
			get_tree().change_scene_to_file("res://boss_fight.tscn") 


func _on_idle_timer_timeout():
	if DataHandler.BossFight == false:
		$IdleSound.volume_db = -30
		$IdleSound.play()
		$AP.play("FadingIdle")
