extends Node3D

@onready var Primary = get_child(0)
@onready var Secondary = get_child(1)

@onready var weaponCount = get_child_count() 
@export var M4A1: PackedScene
var Weapon
var gun
var wepName
var ammoCount
var magSize
var FireRate

# Called when the node enters the scene tree for the first time.
func _ready():
	if weaponCount > 0:
		Primary = get_child(0)
		wepName = Weapon.wepName
		ammoCount = Weapon.ammoCount
		magSize = Weapon.magSize
		FireRate = Weapon.FireRate

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	weaponCount = get_child_count() 
	if Player.weaponout == "primary":
		Weapon = gun
	elif Player.weaponout == "secondary":
		Weapon = Secondary
	if weaponCount > 0:
		Primary = get_child(0)
		if Player.weaponout == "primary":
			Weapon = gun
		elif Player.weaponout == "secondary":
			Weapon = Secondary
		wepName = Weapon.wepName
		ammoCount = Weapon.ammoCount
		magSize = Weapon.magSize
		FireRate = Weapon.FireRate
		print(Weapon)
	if weaponCount == 0:
		gun = M4A1.instantiate()
		add_child(gun)
	weaponCount = get_child_count() 

	print(weaponCount)
