extends "res://Weapon.gd"
#@onready var wepName = "M4A1"
#@onready var ammoCount = 999
#@onready var magSize = 30
#@onready var FireRate = 0.1
#@onready var M4A1 = $"."
@onready var rigidbody = $RigidBody3D
@onready var animation_player = $m4a1AnimationPlayer
@onready var animation_tree = $"M4A1 Animation Tree"
@onready var ads_laser = $"Node3D/RearSight003/ADS-Laser"
@onready var node_3d = $Node3D
@onready var body = $Node3D/Body

var PlayerAnimation
@export var Reloading = false
var MoveBlend = 0
var weaponOut:bool = false
var Player
var rotate
var FiringGun:bool = false
var oldposition
var WeaponStats = {
	wepName = "M4A1",
	damage = 1,
	ammoCount = 120,
	magSize = 30,
	fireRate = 0.1,
	ammoInMag = 30,
	maxAmmo = 120,
}

var pickedUp = false

func TweenFunc(object, value, parameters, time):
	var tween = create_tween()
	if object == animation_tree:
		parameters = "parameters/" + parameters + "/blend_position"
	tween.tween_property(object, parameters, value, time)

func animations():
	if Input.is_action_just_pressed("Reload") and not Reloading and WeaponStats.ammoInMag < WeaponStats.magSize:
		Reloading = true
		animation_tree["parameters/M4A1States/conditions/Reload"] = true
		animation_tree["parameters/M4A1States/conditions/Moving"] = false
		animation_tree["parameters/M4A1States/conditions/ADS"] = false
		animation_tree["parameters/M4A1States/conditions/HipFire"] = false

	if not Reloading:
		if Player.isMoving == "Idle" and not Player.ADS():
			animation_tree["parameters/M4A1States/conditions/Moving"] = true
			TweenFunc(animation_tree, 0, "M4A1States/Movement", .1)
			animation_tree["parameters/M4A1States/conditions/Reload"] = false
			animation_tree["parameters/M4A1States/conditions/ADS"] = false
			animation_tree["parameters/M4A1States/conditions/HipFire"] = false
		elif Player.isMoving == "Walking" and not Player.ADS():
			animation_tree["parameters/M4A1States/conditions/Moving"] = true
			TweenFunc(animation_tree, 1, "M4A1States/Movement", .1)
			animation_tree["parameters/M4A1States/conditions/Reload"] = false
			animation_tree["parameters/M4A1States/conditions/ADS"] = false
			animation_tree["parameters/M4A1States/conditions/HipFire"] = false
		elif Player.isMoving == "Sprint" and not Player.ADS() and not Player.sliding:
			animation_tree["parameters/M4A1States/conditions/Moving"] = true
			TweenFunc(animation_tree, 2, "M4A1States/Movement", .1)
			animation_tree["parameters/M4A1States/conditions/Reload"] = false
			animation_tree["parameters/M4A1States/conditions/ADS"] = false
			animation_tree["parameters/M4A1States/conditions/HipFire"] = false
		if Player.ADS() and Player.isMoving == "Idle" or Player.ADS() and Player.sliding:
			animation_tree["parameters/M4A1States/conditions/ADS"] = true
			TweenFunc(animation_tree, 0, "M4A1States/ADS", .1)
			animation_tree["parameters/M4A1States/conditions/Moving"] = false
			animation_tree["parameters/M4A1States/conditions/Reload"] = false
			animation_tree["parameters/M4A1States/conditions/HipFire"] = false
		elif Player.ADS() and Player.isMoving == "Walking":
			animation_tree["parameters/M4A1States/conditions/ADS"] = true
			animation_tree["parameters/M4A1States/ADS/blend_position"] = 1
#			TweenFunc(animation_tree, 1, "M4A1States/ADS", .1)
			animation_tree["parameters/M4A1States/conditions/Moving"] = false
			animation_tree["parameters/M4A1States/conditions/Reload"] = false
			animation_tree["parameters/M4A1States/conditions/HipFire"] = false
		if shooting() and Player.ADS():
			if FiringGun == false:
				shoot()
			animation_tree["parameters/M4A1States/conditions/ADS"] = true
			animation_tree["parameters/M4A1States/ADS/blend_position"] = 2
			animation_tree["parameters/M4A1States/conditions/Moving"] = false
			animation_tree["parameters/M4A1States/conditions/Reload"] = false
			animation_tree["parameters/M4A1States/conditions/HipFire"] = false
		elif shooting() and not Player.ADS():
			animation_tree["parameters/M4A1States/conditions/HipFire"] = true
			animation_tree["parameters/M4A1States/conditions/Moving"] = false
			animation_tree["parameters/M4A1States/conditions/Reload"] = false
			animation_tree["parameters/M4A1States/conditions/ADS"] = false

func wepswap():
	if PlayerAnimation == "Swap-out":
		animation_tree["parameters/conditions/Swap-out"] = true
		animation_tree["parameters/conditions/Swap-in"] = false
		animation_tree["parameters/M4A1States/conditions/Moving"] = false
		animation_tree["parameters/M4A1States/conditions/ADS"] = false
		animation_tree["parameters/M4A1States/conditions/Reload"] = false
		animation_tree["parameters/M4A1States/conditions/HipFire"] = false

	elif PlayerAnimation == "Swap-in":
		animation_tree["parameters/conditions/Swap-in"] = true
		animation_tree["parameters/conditions/Swap-out"] = false
		animation_tree["parameters/M4A1States/conditions/Moving"] = false
		animation_tree["parameters/M4A1States/conditions/ADS"] = false
		animation_tree["parameters/M4A1States/conditions/Reload"] = false
		animation_tree["parameters/M4A1States/conditions/HipFire"] = false

func reload():
	var reloadAmo = WeaponStats.magSize - WeaponStats.ammoInMag
	if reloadAmo >= WeaponStats.ammoCount:
		WeaponStats.ammoInMag += WeaponStats.ammoCount
		WeaponStats.ammoCount -= reloadAmo
	else:
		WeaponStats.ammoInMag = WeaponStats.magSize
		WeaponStats.ammoCount -= reloadAmo

func _ready():
	pass

func shoot():
	if WeaponStats.ammoInMag != 0:
		if FiringGun == false:
			FiringGun = true
			oldposition = Player.neck.rotation.x
		WeaponStats.ammoInMag -= 1
		if ads_laser.is_colliding():
			var ObjectHit = ads_laser.get_collider()
			if ObjectHit.is_in_group("canTakeDamage"):
				ObjectHit.TakeDamage(WeaponStats.damage)
		if Player.ADS():
			Player.neck.rotation.x += .02
	

func shooting():
	if Input.is_action_pressed("Shoot") and not WeaponStats.ammoInMag <= 0: return true
	else: return false

func _process(delta):
	wepswap()
	if pickedUp:
		if weaponOut:
			visible = true
			animations()
	if Input.is_action_just_released("Shoot") and FiringGun and Player.ADS():
		$Timer.start()

func PickedUp(player):
	Player = player
	pickedUp = true
	animation_tree.active = true
	freeze = true
	collision_layer = 0
	collision_mask = 0
	for child in node_3d.get_children():
					if child is MeshInstance3D:
						child.set_layer_mask_value(1, false)
						child.set_layer_mask_value(2, true)
func Gun():
	pass

func PickUp():
	queue_free()

func _on_timer_timeout():
	print("return")
	TweenFunc(Player.neck, oldposition, "rotation:x", .1)
	FiringGun = false
	animation_tree["parameters/M4A1States/ADS/blend_position"] = 0
