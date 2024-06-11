extends Node2D

@onready var BulletManager = $BulletManager
@onready var Player = $Player

func _ready():
	Player.player_fired_bullet.connect(Callable(BulletManager,"handle_bullet_spawned"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
