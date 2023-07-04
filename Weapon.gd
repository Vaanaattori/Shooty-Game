extends Node3D
@onready var body = $"."
@onready var pick_up_range = $"../../../PickUpRange"
@onready var Player = $"../../.."

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
	Weapon.position = Vector3(0.5,-.53,-.66)
	print(Weapon.position)
	Weapon.rotation = Vector3(0,-180, 0)

	Weapon.scale = Vector3(0.21,0.21,0.21)
	Weapon.NoClip()
	PlayerStats.PrimaryWeapon = Weapon.WeaponStats
	PlayerStats.weaponout = "primary"
	print(get_child(0))
	Player.M4A1_animation_tree.anim_player = "RigidBody3D/m4a1AnimationPlayer"
	Player.M4A1_animation_tree.active = true
	print(Player.M4A1_animation_tree.anim_player)
	weaponCount = get_child_count()
#@onready var wepName = "M4A1"
#@onready var ammoCount = 999
#@onready var magSize = 30
#@onready var FireRate = 0.1
#@onready var M4A1 = $"."
#@onready var rigidbody = $RigidBody3D

