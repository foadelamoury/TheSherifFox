extends CharacterBody2D
@export var range:float = 250
@export var weapon_equipped:Weapon
@export var bullet_type:PackedScene
@export var accuracy:float = 0.5
@export var shooting_speed:float = 2
@export var reload_speed:float = 2
@export var health = 3:
	set(value):
		health = value
		if health == 0:
			die()
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
@onready var AnimPlayer:AnimationPlayer = $AnimationPlayer
@onready var PickUpItem = preload("res://Scenes/pick_up_item.tscn")
func _ready():
	
	if weapon_equipped:
		weapon_equipped = weapon_equipped.duplicate()
		weapon_equipped.bullet_type = bullet_type
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
	if velocity == Vector2(0,0):
		if not AnimPlayer.is_playing():
			AnimPlayer.play("IDLE")
	else:
		if not AnimPlayer.is_playing():
			AnimPlayer.play("WALK")
	move_and_slide()

func die():
	var new_pickup = PickUpItem.instantiate()
	var item = new_pickup.get_child(0)
	var icon:TextureRect = new_pickup.get_child(0).get_child(0)
	item.item_ID = weapon_equipped.item_ID
	#icon.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	get_tree().get_root().call_deferred("add_child", new_pickup)
	new_pickup.global_position = global_position + Vector2(randf_range(0,3),randf_range(0,3))
	queue_free()
