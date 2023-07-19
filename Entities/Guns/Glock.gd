extends RigidBody3D
@onready var rigidbody = $RigidBody3D
var Player
@onready var animation_tree = $GlockAnimationTree
@onready var animation_player = $GlockAnimationPlayer
@onready var node_3d = $Node3D


var PlayerAnimation
@export var Reloading = false
var MoveBlend = 0
var weaponOut:bool = false
var RecoilRotation
var oldposition
var shooting:bool = false

var WeaponStats = {
	wepName = "Glock19",
	damage = 1,
	maxAmmo = 60,
	ammoCount = 60,
	magSize = 15,
	fireRate = 0.1,
	ammoInMag = 15,
}

var pickedUp = false

func TweenFunc(object, value, parameters, time):
	if object == Player.Neck:
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
		if Input.is_action_just_pressed("Shoot") and Player.ADS() and not WeaponStats.ammoInMag == 0:
			animation_tree["parameters/GlockStates/conditions/Shoot"] = true
			animation_tree["parameters/GlockStates/conditions/ADS"] = false
			animation_tree["parameters/GlockStates/conditions/Moving"] = false
			animation_tree["parameters/GlockStates/conditions/Reload"] = false
			animation_tree["parameters/GlockStates/conditions/HipFire"] = false
		elif Input.is_action_just_pressed("Shoot") and not Player.ADS():
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
		oldposition = Player.Neck.rotation.x
	WeaponStats.ammoInMag -= 1
	if Player.ADS():
		$Timer.start()
		Player.Neck.rotation.x += .025

func _process(delta):
	wepswap()
	if pickedUp:
		if weaponOut:
			visible = true
			animations()

func PickedUp(player):
	Player = player
	pickedUp = true
	animation_tree.active = true
	freeze = true
	collision_layer = 0
	collision_mask = 0
	$"Node3D/Chamber/Back Sights/Sights".set_layer_mask_value(1, false)
	$"Node3D/Chamber/Back Sights/Sights".set_layer_mask_value(2, true)
	for child in node_3d.get_children():
			if child is MeshInstance3D:
				child.set_layer_mask_value(1, false)
				child.set_layer_mask_value(2, true)
				var childcount = child.get_child_count()
				if childcount > 0:
					for child2 in child.get_children():
						if child2 is MeshInstance3D:
							child2.set_layer_mask_value(1, false)
							child2.set_layer_mask_value(2, true)
func Gun():
	pass

func PickUp():
	queue_free()

func _on_timer_timeout():
	print("return")
	TweenFunc(Player.Neck, oldposition, "rotation:x", .1)
	shooting = false
	animation_tree["parameters/GlockStates/ADS/blend_position"] = 0

