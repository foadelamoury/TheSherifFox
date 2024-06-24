extends Node2D

@export var BasicBullet:PackedScene
@onready var Anima = $AnimatedSprite2D
var health = 50
var Phase = 1
var csStarted = false
var BulletType = load("res://Scenes/enemy_bullet_Arrow.tscn")

func _ready():
	DataHandler.bosspos = global_position
	get_parent().get_node("AnimationPlayer").play("BossEntry")
	$AnimatedSprite2D.play("Front")
	DataHandler.BossFight = true
	#As player have it's own camera.... I added it

func _process(delta):
	#for Cutscene
	$RockClapPivot.look_at(get_parent().get_node("CanvasLayer/Player").global_position)
	
	get_parent().get_node("CanvasLayer/Player/BossHealthBar").value = health
	if health <= 0:
		health = 0
		queue_free()
	
	
func FightStartCutscene():
	csStarted = true
	Anima.play("RotatingPhaseAlert")
	DataHandler.CameraShake = true

func _on_scream_finished():
	DataHandler.bosspos = null
	DataHandler.CameraShake = false
	
func _on_animation_player_animation_finished(anim_name):
	
	if anim_name == "RockClap":
		DataHandler.CameraShake = true
		
		#Shoot
		DataHandler.BulletTex = "Stone"
		#DataHandler.bulletsize = 0.045
		var bullet = BulletType
		var bullet_instance = bullet.instantiate()
		var bullet_position = $RockClapPivot/GunSprite/EndOfGun.global_position
		var bullet_direction = ($RockClapPivot/GunSprite/GunDirection.global_position - $RockClapPivot/GunSprite/EndOfGun.global_position).normalized()
		get_tree().get_root().add_child(bullet_instance)
		bullet_instance.global_position = bullet_position
		bullet_instance.set_direction(bullet_direction)
		
		$AttackTimers/CamShake.start()
		if Phase == 1:
			randomize()
			$AttackTimers/RockClap.wait_time = randi_range(2, 6)
			$AttackTimers/RockClap.start()
		$Hands/right.position = Vector2(43.75, 27.5)
		$Hands/left.position = Vector2(-43.75, 27.5)
		
	
	if DataHandler.cutscene and not csStarted:
		FightStartCutscene()
		DataHandler.cutscene = false
		$AttackTimers/RockClap.start()


func _on_timer_timeout():
	get_parent().get_node("AnimationPlayer").play("RockClap")


func _on_cam_shake_timeout():
	DataHandler.CameraShake = false
