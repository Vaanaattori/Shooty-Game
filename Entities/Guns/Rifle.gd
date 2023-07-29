extends RigidBody3D
var PlayerAnimation
@onready var MeshNode = $MeshNode
@onready var Player = Global.Player
var weaponOut:bool = true
var FiringGun:bool = false
var pickedUp:bool = true
var oldposition
var ads_laser
var animation_player
var PlayOnce:bool = false
@export var Reloading:bool = false
@export var WeaponStats = {
	wepName = "",
	damage = 0,
	maxAmmo = 0,
	ammoCount = 0,
	magSize = 0,
	fireRate = 0,
	ammoInMag = 0,
}

func _ready():
	WeaponStats.ammoInMag = WeaponStats.magSize

func TweenFunc(object, value, parameters, time):
	var tween = create_tween()
	tween.tween_property(object, parameters, value, time)

func animations():
	if not Input.is_action_pressed("Shoot"):
		animation_player.speed_scale = 1
	if Input.is_action_just_pressed("Reload") and not Player.Reloading and WeaponStats.magSize > WeaponStats.ammoInMag and WeaponStats.ammoCount > 0:
		Player.Reloading = true
		animation_player.speed_scale = 1
		animation_player.stop()
		animation_player.play("Reload")
	if not Player.Reloading:
		if Player.ADS():
			if not Input.is_action_pressed("Shoot") or WeaponStats.ammoInMag <= 0:
				print("idle ads")
				animation_player.speed_scale = 1
				animation_player.play("ADS_Idle")
			elif Input.is_action_pressed("Shoot") and not WeaponStats.ammoInMag <= 0:
				print("firing ads")
				animation_player.speed_scale = WeaponStats.fireRate
				animation_player.play("ADS_Fire")
			PlayOnce = false
		elif not PlayOnce:
			animation_player.play("RESET_2")
			PlayOnce = true
func reload():
	var reloadAmo = WeaponStats.magSize - WeaponStats.ammoInMag
	if reloadAmo >= WeaponStats.ammoCount:
		WeaponStats.ammoInMag += WeaponStats.ammoCount
		WeaponStats.ammoCount -= reloadAmo
	else:
		WeaponStats.ammoInMag = WeaponStats.magSize
		WeaponStats.ammoCount -= reloadAmo
	

func shoot():
	if not WeaponStats.ammoInMag <= 0:
		if FiringGun == false:
			FiringGun = true
			oldposition = Player.Neck.rotation.x
		WeaponStats.ammoInMag -= 1
		if ads_laser.is_colliding():
			var ObjectHit = ads_laser.get_collider()
			if ObjectHit != null:
				if ObjectHit.is_in_group("canTakeDamage"):
					ObjectHit.TakeDamage(WeaponStats.damage)
		Player.Neck.rotation.x += .02
		$Timer.start()

func PickedUp():
	pickedUp = true
#	animation_tree.active = true
	freeze = true
	collision_layer = 0
	collision_mask = 0
	for child in MeshNode.get_children():
		if child is MeshInstance3D:
			child.set_layer_mask_value(1, false)
			child.set_layer_mask_value(2, true)

func Gun():
	pass

func PickUp():
	queue_free()

func _on_timer_timeout():
	print("return")
	if oldposition < Player.Neck.rotation.x:
		TweenFunc(Player.Neck, oldposition, "rotation:x", .1)
	FiringGun = false
#	animation_tree["parameters/M4A1States/ADS/blend_position"] = 0
