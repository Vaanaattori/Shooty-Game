extends RigidBody3D

#@onready var wepName = "M4A1"
#@onready var ammoCount = 999
#@onready var magSize = 30
#@onready var FireRate = 0.1
#@onready var M4A1 = $"."
@onready var rigidbody = $RigidBody3D
@onready var animation_tree = $AnimationTree
@onready var Player = get_node("../Player")
@onready var animation_player = $m4a1AnimationPlayer



var WeaponStats = {
	wepName = "M4A1",
	ammoCount = 999,
	magSize = 30,
	fireRate = 0.1,
	ammoInMag = 30,
}

var pickedUp = false

func _ready():
	pass

func _process(delta):
	if pickedUp:
		freeze = true
	else:
		freeze = false
#	Player = get_node("../Player")

func animations():
	pass

func Gun():
	pass

func NoClip():
	collision_layer = 0
	print("rigidbody.collision_layer  ", collision_layer)

#func PickUp():
#	queue_free()
