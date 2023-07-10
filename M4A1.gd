extends "res://Weapon.gd"
#@onready var wepName = "M4A1"
#@onready var ammoCount = 999
#@onready var magSize = 30
#@onready var FireRate = 0.1
#@onready var M4A1 = $"."
@onready var rigidbody = $RigidBody3D
@onready var animation_player = $m4a1AnimationPlayer
@onready var animation_tree = $"M4A1 Animation Tree"

var PlayerAnimation
@export var Reloading = false
var MoveBlend = 0
var weaponOut:bool = false
var Player

var WeaponStats = {
	wepName = "M4A1",
	ammoCount = 999,
	magSize = 30,
	fireRate = 0.1,
	ammoInMag = 30,
}

var pickedUp = false

func TweenFunc(value, parameters, time):
	var tween = create_tween()
	parameters = "parameters/" + parameters + "/blend_position"
	tween.tween_property(animation_tree, parameters, value, time)

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
			TweenFunc(0, "M4A1States/Movement", .1)
			animation_tree["parameters/M4A1States/conditions/Reload"] = false
			animation_tree["parameters/M4A1States/conditions/ADS"] = false
			animation_tree["parameters/M4A1States/conditions/HipFire"] = false
		elif Player.isMoving == "Walking" and not Player.ADS():
			animation_tree["parameters/M4A1States/conditions/Moving"] = true
			TweenFunc(1, "M4A1States/Movement", .1)
			animation_tree["parameters/M4A1States/conditions/Reload"] = false
			animation_tree["parameters/M4A1States/conditions/ADS"] = false
			animation_tree["parameters/M4A1States/conditions/HipFire"] = false
		elif Player.isMoving == "Sprint" and not Player.ADS():
			animation_tree["parameters/M4A1States/conditions/Moving"] = true
			TweenFunc(2, "M4A1States/Movement", .1)
			animation_tree["parameters/M4A1States/conditions/Reload"] = false
			animation_tree["parameters/M4A1States/conditions/ADS"] = false
			animation_tree["parameters/M4A1States/conditions/HipFire"] = false
		elif Player.ADS() and Player.isMoving == "Idle":
			animation_tree["parameters/M4A1States/conditions/ADS"] = true
			TweenFunc(0, "M4A1States/ADS", .1)
			animation_tree["parameters/M4A1States/conditions/Moving"] = false
			animation_tree["parameters/M4A1States/conditions/Reload"] = false
			animation_tree["parameters/M4A1States/conditions/HipFire"] = false
		elif Player.ADS() and Player.isMoving == "Walking":
			animation_tree["parameters/M4A1States/conditions/ADS"] = true
			TweenFunc(1, "M4A1States/ADS", .1)
			animation_tree["parameters/M4A1States/conditions/Moving"] = false
			animation_tree["parameters/M4A1States/conditions/Reload"] = false
			animation_tree["parameters/M4A1States/conditions/HipFire"] = false
		if shooting() and Player.ADS():
			animation_tree["parameters/M4A1States/conditions/ADS"] = true
			TweenFunc(2, "M4A1States/ADS", .1)
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
	WeaponStats.ammoInMag -= 1

func shooting():
	if Input.is_action_pressed("Primary Action") and not WeaponStats.ammoInMag <= 0: return true
	else: return false
func _process(delta):
	wepswap()
	if pickedUp:
#		Player = get_node("../Player")
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
