extends Node

@export var PlayerLoad: PackedScene

@onready var Player = PlayerLoad.instantiate()

@export var WeaponPreload = {Weapon1 = "MP5", Weapon2 = "M4A1", Weapon3 = "Glock"}

var WeaponList = {}

func _ready():
	print("test")
	for gun in WeaponPreload:
		var GunName = WeaponPreload[gun]
		var LoadPath = "res://Entities/Guns/{0}.tscn".format([GunName])
		print(LoadPath)
		var Weapon = load(str(LoadPath))
		WeaponList[GunName] = Weapon
