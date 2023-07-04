extends Node3D
@onready var body = $"."
@onready var pick_up_range = $"../../../PickUpRange"

var weaponCount = get_child_count()

func _ready():
	pass
	
func _process(delta):
	pass

func gunPickUp(Gun):
	print("Picked up: ",Gun.name)
	Gun = load("res://Guns/" + str(Gun.name) + ".tscn")
	var Weapon = Gun.instantiate()
	add_child(Weapon)
	Weapon.pickedUp = true
	Weapon.position = Vector3(0,0.006,0)
	Weapon.rotation = Vector3.ZERO
	Weapon.scale = Vector3(0.21,0.21,0.21)
	Weapon.NoClip()
	PlayerStats.PrimaryWeapon = Weapon.WeaponStats
	PlayerStats.weaponout = "primary"

	weaponCount = get_child_count()
#@onready var wepName = "M4A1"
#@onready var ammoCount = 999
#@onready var magSize = 30
#@onready var FireRate = 0.1
#@onready var M4A1 = $"."
#@onready var rigidbody = $RigidBody3D

