extends Node2D

@onready var BulletManager = $BulletManager
@onready var BulletUI = $BulletUI
@onready var Player = $Player

func _ready():
	Player.player_fired_bullet.connect(Callable(BulletManager,"handle_bullet_spawned"))

