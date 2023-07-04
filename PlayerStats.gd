extends Node

@export_group("Stats")
@export var HPMax = 100
@export var HP = 100
@export var MaxStamina = 25
@export var stamina = 200
@export var StaminaRecovery = 10
@export var BaseSpeed = 4
@export var SprintMultiplier = 2
@export_group("Weapon Stats")
@export var SlideLength = 1.25

@export_group("Settings")
@export var sensitivity = 10

@export_group("GunStats")

var weaponout = ""
#
#var wepName
#var ammoCount
#var magSize
#var FireRate
#var ammoInMag

func _process(delta):
	if weaponout == "primary":
		CurrentWeapon = PrimaryWeapon
	if weaponout == "secondary":
		CurrentWeapon = SecondaryWeapon
	if weaponout == "melee":
		CurrentWeapon = MeleeWeapon

var CurrentWeapon = {
	wepName = "test",
	ammoCount = 0,
	magSize = 0,
	fireRate = 0,
	ammoInMag = 0,
}

var PrimaryWeapon = {
	wepName = "Empty",
	ammoCount = 0,
	magSize = 0,
	FireRate = 0,
	ammoInMag = 0,
}

var SecondaryWeapon = {
	wepName = "Empty",
	ammoCount = 0,
	magSize = 0,
	FireRate = 0,
	ammoInMag = 0,
}

var MeleeWeapon = {
	wepName = "Fists",
	ammoCount = 0,
	magSize = 0,
	FireRate = 1,
	ammoInMag = 0,
}

var Sec_wepName
var Sec_ammoCount
var Sec_magSize
var Sec_FireRate
