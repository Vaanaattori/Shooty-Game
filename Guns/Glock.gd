extends "res://Weapon.gd"
@onready var rigidbody = $RigidBody3D
@onready var Player = get_node("../Player")
@onready var animation_tree = $GlockAnimationTree
@onready var animation_player = $GlockAnimationPlayer


var PlayerAnimation
@export var Reloading = false
var MoveBlend = 0
var weaponOut:bool = false
var RecoilRotation
var oldposition
var shooting:bool = false

var WeaponStats = {
	wepName = "Glock19",
	ammoCount = 999,
	magSize = 15,
	fireRate = 0.1,
	ammoInMag = 15,
}

var pickedUp = false

func TweenFunc(object, value, parameters, time):
	if object == Player.neck:
		print(object)
	var tween = create_tween()
	if object == animation_tree:
		parameters = "parameters/" + parameters + "/blend_position"
	tween.tween_property(object, parameters, value, time)
#M4A1States/Movement 0

func animations():
	if Input.is_action_just_pressed("Reload") and not Reloading and WeaponStats.ammoInMag < WeaponStats.magSize:
		Reloading = true
		animation_tree["parameters/GlockStates/conditions/Reload"] = true
		animation_tree["parameters/GlockStates/conditions/Moving"] = false
		animation_tree["parameters/GlockStates/conditions/ADS"] = false
		animation_tree["parameters/GlockStates/conditions/HipFire"] = false
		animation_tree["parameters/GlockStates/conditions/Shoot"] = false
	if not Reloading:
		if Player.isMoving == "Idle" and not Player.ADS():
			animation_tree["parameters/GlockStates/conditions/Moving"] = true
			TweenFunc(animation_tree, -1, "GlockStates/Movement", .1)
			animation_tree["parameters/GlockStates/conditions/Reload"] = false
			animation_tree["parameters/GlockStates/conditions/ADS"] = false
			animation_tree["parameters/GlockStates/conditions/HipFire"] = false
			animation_tree["parameters/GlockStates/conditions/Shoot"] = false
		elif Player.isMoving == "Walking" and not Player.ADS():
			animation_tree["parameters/GlockStates/conditions/Moving"] = true
			TweenFunc(animation_tree, 0, "GlockStates/Movement", .1)
			animation_tree["parameters/GlockStates/conditions/Reload"] = false
			animation_tree["parameters/GlockStates/conditions/ADS"] = false
			animation_tree["parameters/GlockStates/conditions/HipFire"] = false
			animation_tree["parameters/GlockStates/conditions/Shoot"] = false
		elif Player.isMoving == "Sprint" and not Player.ADS():
			animation_tree["parameters/GlockStates/conditions/Moving"] = true
			TweenFunc(animation_tree, 1, "GlockStates/Movement", .1)
			animation_tree["parameters/GlockStates/conditions/Reload"] = false
			animation_tree["parameters/GlockStates/conditions/ADS"] = false
			animation_tree["parameters/GlockStates/conditions/HipFire"] = false
			animation_tree["parameters/GlockStates/conditions/Shoot"] = false
		elif Player.ADS() and Player.isMoving == "Idle":
			animation_tree["parameters/GlockStates/conditions/ADS"] = true
			TweenFunc(animation_tree, 0, "GlockStates/ADS", .1)
			animation_tree["parameters/GlockStates/conditions/Moving"] = false
			animation_tree["parameters/GlockStates/conditions/Reload"] = false
			animation_tree["parameters/GlockStates/conditions/HipFire"] = false
			animation_tree["parameters/GlockStates/conditions/Shoot"] = false
		elif Player.ADS() and Player.isMoving == "Walking":
			animation_tree["parameters/GlockStates/conditions/ADS"] = true
			TweenFunc(animation_tree, 1, "GlockStates/ADS", .1)
			animation_tree["parameters/GlockStates/conditions/Moving"] = false
			animation_tree["parameters/GlockStates/conditions/Reload"] = false
			animation_tree["parameters/GlockStates/conditions/HipFire"] = false
			animation_tree["parameters/GlockStates/conditions/Shoot"] = false
		if Input.is_action_just_pressed("Primary Action") and Player.ADS() and not WeaponStats.ammoInMag == 0:
			animation_tree["parameters/GlockStates/conditions/Shoot"] = true
			animation_tree["parameters/GlockStates/conditions/ADS"] = false
			animation_tree["parameters/GlockStates/conditions/Moving"] = false
			animation_tree["parameters/GlockStates/conditions/Reload"] = false
			animation_tree["parameters/GlockStates/conditions/HipFire"] = false
		elif Input.is_action_just_pressed("Primary Action") and not Player.ADS():
			animation_tree["parameters/GlockStates/conditions/HipFire"] = true
			animation_tree["parameters/GlockStates/conditions/Moving"] = false
			animation_tree["parameters/GlockStates/conditions/Reload"] = false
			animation_tree["parameters/GlockStates/conditions/ADS"] = false
			animation_tree["parameters/GlockStates/conditions/Shoot"] = false

func wepswap():
	if PlayerAnimation == "Swap-out":
		animation_tree["parameters/conditions/Swap-out"] = true
		animation_tree["parameters/conditions/Swap-in"] = false
		animation_tree["parameters/GlockStates/conditions/Moving"] = false
		animation_tree["parameters/GlockStates/conditions/ADS"] = false
		animation_tree["parameters/GlockStates/conditions/Shoot"] = false
		animation_tree["parameters/GlockStates/conditions/Reload"] = false
		animation_tree["parameters/GlockStates/conditions/HipFire"] = false

	elif PlayerAnimation == "Swap-in":
		animation_tree["parameters/conditions/Swap-in"] = true
		animation_tree["parameters/conditions/Swap-out"] = false
		animation_tree["parameters/GlockStates/conditions/Moving"] = false
		animation_tree["parameters/GlockStates/conditions/Shoot"] = false
		animation_tree["parameters/GlockStates/conditions/ADS"] = false
		animation_tree["parameters/GlockStates/conditions/Reload"] = false
		animation_tree["parameters/GlockStates/conditions/HipFire"] = false

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
	if shooting == false:
		shooting = true
		oldposition = Player.neck.rotation.x
	WeaponStats.ammoInMag -= 1
	if Player.ADS():
		$Timer.start()
		Player.neck.rotation.x += .025

func _process(delta):
	wepswap()
	if pickedUp:
		if weaponOut:
			visible = true
			animations()

func PickedUp():
	freeze = true
	collision_layer = 0
	collision_mask = 0

func Gun():
	pass

func PickUp():
	queue_free()

func _on_timer_timeout():
	print("return")
	TweenFunc(Player.neck, oldposition, "rotation:x", .1)
	shooting = false
	animation_tree["parameters/GlockStates/ADS/blend_position"] = 0

