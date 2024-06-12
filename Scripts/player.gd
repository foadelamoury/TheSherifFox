extends CharacterBody2D

signal player_fired_bullet(Bullet,bullet_position,bullet_direction)

@onready var weapon_pivot = $WeaponPivot
@onready var weapon_sprite = $WeaponPivot/GunSprite
@onready var EndOfGun = $WeaponPivot/EndOfGun
@onready var GunDirection = $WeaponPivot/GunDirection
@export var bullet :PackedScene
@export var movement_speed = 300.0
@export var direction_speed = 1.2

# TODO: Please make an @onready reference to the Animation Player to be consistent in the coding style
# TODO: Please be typesafe with function return types not inherited from base class (e.g. shoot())

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
		$Sprite2D.flip_h = false
		weapon_sprite.flip_v = false
	elif mouse_direction.x < 0 and !$Sprite2D.flip_h:
		$Sprite2D.flip_h = true
		weapon_sprite.flip_v = true
	move_and_slide()
	weapon_pivot.look_at(get_global_mouse_position())
	
func _unhandled_input(event):
	if event.is_action_released("shoot"):
		shoot()
		
func shoot():
	var bullet_instance = bullet.instantiate()
	var bullet_position = EndOfGun.global_position
	var bullet_direction = (GunDirection.global_position - EndOfGun.global_position).normalized()
	player_fired_bullet.emit(bullet_instance,bullet_position,bullet_direction)
