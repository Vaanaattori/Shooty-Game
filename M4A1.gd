extends Node3D

#@onready var wepName = "M4A1"
#@onready var ammoCount = 999
#@onready var magSize = 30
#@onready var FireRate = 0.1
#@onready var M4A1 = $"."
@onready var rigidbody = $RigidBody3D

var WeaponStats = {
	wepName = "M4A1",
	ammoCount = 999,
	magSize = 30,
	fireRate = 0.1,
	ammoInMag = 30,
}

var pickedUp = false

func _process(delta):
	if pickedUp:
		rigidbody.freeze = true
	else:
		rigidbody.freeze = false

func Gun():
	pass

func NoClip():
	rigidbody.collision_layer = 0
	print("rigidbody.collision_layer  ",rigidbody.collision_layer)

func PickUp():
	queue_free()
