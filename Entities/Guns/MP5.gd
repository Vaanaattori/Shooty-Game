extends "res://Entities/Guns/Rifle.gd"
@onready var test = $AnimationPlayer
@onready var ammo_counter = $AmmoCounter/Screen/AmmoLabel
var halfAmmo:int

func _ready():
	halfAmmo = WeaponStats.maxAmmo / 2
	animation_player = $AnimationPlayer
	ads_laser = $MeshNode/Cylinder_005/RayCast3D
	

func _process(_delta):
	if pickedUp:
		if weaponOut:
			Player.Reloading = Player.Reloading
			visible = true
			animations()
