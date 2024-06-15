extends CharacterBody2D
@export var range:float = 250
@export var weapon_equipped:Weapon
@export var accuracy:float = 0.5
@export var shooting_speed:float = 2
@export var reload_speed:float = 2
#short range 200
#mid range 400
#long range 600
@onready var sprite_2d = $Sprite2D
@onready var weapon_pivot:Node2D = $WeaponPivot
@onready var weapon_sprite = $WeaponPivot/GunSprite
@onready var EndOfGun = $WeaponPivot/GunSprite/EndOfGun
@onready var GunDirection = $WeaponPivot/GunSprite/GunDirection
@onready var shootTimer:Timer = $ShootTimer
@onready var reloadTimer:Timer = $ReloadTimer
@onready var waitTimer:Timer = $WaitTimer
func _ready():
	
	if weapon_equipped:
		weapon_equipped = weapon_equipped.duplicate()
		weapon_sprite.texture = weapon_equipped.icon
		shootTimer.wait_time = shooting_speed
		reloadTimer.wait_time = reload_speed
		weapon_sprite.texture = weapon_equipped.icon
		weapon_pivot.rotation = 0
		EndOfGun.global_position = weapon_sprite.global_position
		GunDirection.global_position = EndOfGun.global_position
		EndOfGun.global_position.x += 30
		GunDirection.global_position = EndOfGun.global_position
		GunDirection.global_position.x += 5
	else:
		weapon_sprite.texture = null

func _physics_process(delta):
	move_and_slide()
