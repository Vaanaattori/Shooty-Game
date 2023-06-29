extends CharacterBody2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var scan_time = $ScanTime
@onready var marker_2d = $"Marker2D"
@onready var jump_dur = $JumpDur
@onready var hitbox = $Hitbox
@onready var health_bar = $HealthBar
@onready var damage_takencd = $DamageTakencd
@onready var effects = $Effects
@onready var detection_area = $DetectionArea


#---stats---#
@export var maxhealth = MonsterStats.slime_base_health
@export var speed = MonsterStats.slime_base_speed
@export var damage = MonsterStats.slime_base_damage
@export var knockbackres = MonsterStats.slime_base_knockbackres
@export var knockbackstr = MonsterStats.slime_base_knockbackstr
#-----------#

signal enemy_attacking(damage, mobposition, knockbackstrength)

var health = maxhealth
var player_chase : bool = false
var player = null
var player_position = Vector2(0, 0)
var previous_position = global_position
var jumping : bool = false
var takingDamage : bool = false
var dead : bool = false

func is_moving():
	if global_position != previous_position:
		return true 
	else:
		return false 

func printdebug():
	print("Scan Time: ",scan_time.time_left)
	print("Jump Dur: ", jump_dur.time_left)
	print("player pos:", player_position)
	print("is jumping: ", jumping)

func _physics_process(delta):
	if health <= 0:
		death()
	
	is_moving()
	if not is_moving():
		if not jumping and not animated_sprite_2d.is_playing():
			animated_sprite_2d.play("Idle")
	elif not jumping and not animated_sprite_2d.is_playing():
			animated_sprite_2d.play("walk")
	previous_position = global_position

	if hitbox.has_overlapping_bodies():
		signalInfo()
	
	if Global.player_current_attack and hitbox.has_overlapping_areas():
		takeDamage()
	
	knockback()
	healthbar()
	attacking()
	move_and_slide()
	#printdebug()

func signalInfo():
	emit_signal("enemy_attacking", damage, position, knockbackstr)

func attacking():
	if scan_time.time_left > 0 and player_chase and not jumping:
		player_position = player.position
		marker_2d.global_position = player_position
#		marker_2d.position += (player.position - marker_2d.global_position)
	
	if jumping and not takingDamage:
		position += (player_position  - global_position) / speed 
		animated_sprite_2d.play("jump")

func knockback():
	if player_chase and takingDamage:
		var knockbackdir = player_position.direction_to(global_position)
		var knockback = knockbackdir * knockbackstr / knockbackres
		global_position += knockback

func healthbar():
	health_bar.value = health
	health_bar.max_value = maxhealth

func _on_detection_area_body_entered(body):
	print("player spotted")
	player = body
	player_chase = true
	scan_time.start()

func _on_detection_area_body_exited(body):
	player = null
	player_chase = false

func _on_scan_time_timeout():
	jumping = true
	jump_dur.start()

func _on_jump_dur_timeout():
	jumping = false
	if player_chase:
		scan_time.start()

func monster():
	pass

func takeDamage():
	if damage_takencd.time_left == 0:
		damage_takencd.start()
		effects.play("DamageTaken")
		takingDamage = true
		health -= PlayerStats.damage
		animated_sprite_2d.play("damagetaken")
		print("damagetaken")

func _on_damage_takencd_timeout():
	takingDamage = false

func death():

	if not dead:
		animated_sprite_2d.play("death")
		dead = true

	if not animated_sprite_2d.is_playing():
		queue_free()

