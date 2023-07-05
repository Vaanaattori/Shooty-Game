extends "res://Weapon.gd"
#@onready var wepName = "M4A1"
#@onready var ammoCount = 999
#@onready var magSize = 30
#@onready var FireRate = 0.1
#@onready var M4A1 = $"."
@onready var rigidbody = $RigidBody3D
@onready var Player = get_node("../Player")
@onready var animation_player = $m4a1AnimationPlayer
@onready var animation_tree = $"M4A1 Animation Tree"

var PlayerAnimation
var Reloading = false
var MoveBlend = 0
var weaponOut:bool = true

var WeaponStats = {
	wepName = "M4A1",
	ammoCount = 999,
	magSize = 30,
	fireRate = 0.1,
	ammoInMag = 30,
	reloadLength = 2.5,
	reloadTime = 2,
}

var pickedUp = false

func TweenFunc(value, parameters, time):
	var tween = create_tween()
	parameters = "parameters/" + parameters + "/blend_position"
	tween.tween_property(animation_tree, parameters, value, time)
#M4A1States/Movement 0

func animations():
#	print(animation_tree.active)
	if PlayerAnimation == "Reload":
		animation_tree["parameters/M4A1States/conditions/Reload"] = true
		animation_tree["parameters/M4A1States/conditions/Moving"] = false
		animation_tree["parameters/M4A1States/conditions/ADS"] = false
		animation_tree["parameters/M4A1States/conditions/HipFire"] = false
	if PlayerAnimation == "Idle":
		print("idle")
		animation_tree["parameters/M4A1States/conditions/Moving"] = true
		TweenFunc(0, "M4A1States/Movement", .1)
		animation_tree["parameters/M4A1States/conditions/Reload"] = false
		animation_tree["parameters/M4A1States/conditions/ADS"] = false
		animation_tree["parameters/M4A1States/conditions/HipFire"] = false
	elif PlayerAnimation == "Walking": 
		animation_tree["parameters/M4A1States/conditions/Moving"] = true
		TweenFunc(1, "M4A1States/Movement", .1)
		animation_tree["parameters/M4A1States/conditions/Reload"] = false
		animation_tree["parameters/M4A1States/conditions/ADS"] = false
		animation_tree["parameters/M4A1States/conditions/HipFire"] = false
	elif PlayerAnimation == "Sprinting":
		animation_tree["parameters/M4A1States/conditions/Moving"] = true
		TweenFunc(2, "M4A1States/Movement", .1)
		animation_tree["parameters/M4A1States/conditions/Reload"] = false
		animation_tree["parameters/M4A1States/conditions/ADS"] = false
		animation_tree["parameters/M4A1States/conditions/HipFire"] = false
	if PlayerAnimation == "ADS":
		animation_tree["parameters/M4A1States/conditions/ADS"] = true
		TweenFunc(0, "M4A1States/ADS", .1)
		animation_tree["parameters/M4A1States/conditions/Moving"] = false
		animation_tree["parameters/M4A1States/conditions/Reload"] = false
		animation_tree["parameters/M4A1States/conditions/HipFire"] = false
	elif PlayerAnimation == "ADS_Walking":
		animation_tree["parameters/M4A1States/conditions/ADS"] = true
		TweenFunc(1, "M4A1States/ADS", .1)
		animation_tree["parameters/M4A1States/conditions/Moving"] = false
		animation_tree["parameters/M4A1States/conditions/Reload"] = false
		animation_tree["parameters/M4A1States/conditions/HipFire"] = false
	elif PlayerAnimation == "ADS_Firing":
		animation_tree["parameters/M4A1States/conditions/ADS"] = true
		TweenFunc(2, "M4A1States/ADS", .1)
		animation_tree["parameters/M4A1States/conditions/Moving"] = false
		animation_tree["parameters/M4A1States/conditions/Reload"] = false
		animation_tree["parameters/M4A1States/conditions/HipFire"] = false
	if PlayerAnimation == "HipFire":
		animation_tree["parameters/M4A1States/conditions/HipFire"] = true
		animation_tree["parameters/M4A1States/conditions/Moving"] = false
		animation_tree["parameters/M4A1States/conditions/Reload"] = false
		animation_tree["parameters/M4A1States/conditions/ADS"] = false

func wepswap():
		animation_tree["parameters/M4A1States/conditions/Moving"] = false
		animation_tree["parameters/M4A1States/conditions/ADS"] = false
		animation_tree["parameters/M4A1States/conditions/Reload"] = false
		animation_tree["parameters/M4A1States/conditions/HipFire"] = false

		if not Reloading and animation_tree["parameters/conditions/Swap-out"] == false or PlayerAnimation == "Swap-out":
			animation_tree["parameters/conditions/Swap-out"] = true
			animation_tree["parameters/conditions/Swap-in"] = false
			weaponOut = false
		elif not Reloading and animation_tree["parameters/conditions/Swap-out"] == true or PlayerAnimation == "Swap-in":
			animation_tree["parameters/conditions/Swap-in"] = true
			animation_tree["parameters/conditions/Swap-out"] = false
			weaponOut = true

func _ready():
	pass

func _process(delta):
	if pickedUp:
#		print(weaponOut)
		if weaponOut:
			print(PlayerAnimation)
			animations()
#			if Input.is_action_just_pressed("SwapWep"):
#				wepswap()
#		elif not weaponOut:
#			if Input.is_action_just_pressed("SwapWep"):
#				wepswap()

func PickedUp():
	freeze = true
	collision_layer = 0
	collision_mask = 0
	animation_tree.active = true

func Gun():
	pass

func PickUp():
	queue_free()
