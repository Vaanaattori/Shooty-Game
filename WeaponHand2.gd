extends Node3D
@onready var body = $"."
@onready var pick_up_range = $"../../../PickUpRange"
@onready var Player = $"../../.."
@onready var weaponswap_out_dur = $"../../../Timers/WeaponSwapOutDur"
@onready var weaponswap_in_dur = $"../../../Timers/WeaponSwapInDur"
@onready var LoadM4A1 = preload("res://Guns/M4A1.tscn")
@onready var LoadGlock = preload("res://Guns/Glock.tscn")
var WeaponList = {
	PrimaryWeapon = null,
	SecondaryWeapon = null,
	MeleeWeapon = null,
}
var preloadDictionary = {}
var CurrentWeapon
var SwappingTo
var swapping:bool = false
var weaponCount = get_child_count()

func _ready():
	preloadDictionary["M4A1"] = LoadM4A1
	preloadDictionary["Glock"] = LoadGlock
	
func _process(delta):
	selectWeapon("")
	if not swapping and CurrentWeapon != null:
		CurrentWeapon.PlayerAnimation = Player.animationtoplay
func selectWeapon(wep):
	#when primary selected
	if weaponCount > 0:
		if not CurrentWeapon.Reloading and not swapping:
			SwappingTo = wep
			if Input.is_action_just_pressed("PrimaryWep") and not CurrentWeapon == WeaponList.PrimaryWeapon and weaponCount > 1 or wep == "primary":
				WeaponSwap(WeaponList.PrimaryWeapon)
			elif Input.is_action_just_pressed("SecondaryWep") and not CurrentWeapon == WeaponList.SecondaryWeapon and weaponCount > 1 or wep == "secondary":
				WeaponSwap(WeaponList.SecondaryWeapon)
func WeaponSwap(SwappingTo):
	swapping = true
	print("Swapping From: ", CurrentWeapon," To: ", SwappingTo)
	CurrentWeapon.PlayerAnimation = "Swap-out"
	CurrentWeapon.weaponOut = false
	CurrentWeapon = SwappingTo
	weaponswap_out_dur.start()
func weaponswap_out_timeout():
	CurrentWeapon.visible = true
	CurrentWeapon.PlayerAnimation = "Swap-in"
	CurrentWeapon.weaponOut = true
	weaponswap_in_dur.start()
func weaponswap_in_timeout():
	swapping = false
	CurrentWeapon.weaponOut = true

func gunPickUp(Gun):
	weaponCount = get_child_count()
	if WeaponList.PrimaryWeapon == null:
		print("Primary empty adding: ",Gun.name)
		if preloadDictionary.has(Gun.name):
			# Instantiate the corresponding preloaded scene
			WeaponList.PrimaryWeapon = preloadDictionary[Gun.name].instantiate()
			add_child(WeaponList.PrimaryWeapon)
#		CurrentWeapon = WeaponList.PrimaryWeapon
		WeaponList.PrimaryWeapon.PickedUp(Player)
		if CurrentWeapon == null:
			CurrentWeapon = WeaponList.PrimaryWeapon
			CurrentWeapon.visible = true
			CurrentWeapon.PlayerAnimation = "Swap-in"
			print(CurrentWeapon.PlayerAnimation)
			weaponswap_in_dur.start()
		else:
			selectWeapon("primary")
	
	elif WeaponList.SecondaryWeapon == null:
		print("Picked up: ",Gun.name)
		if preloadDictionary.has(Gun.name):
			# Instantiate the corresponding preloaded scene
			WeaponList.SecondaryWeapon = preloadDictionary[Gun.name].instantiate()
			add_child(WeaponList.SecondaryWeapon)
		WeaponList.SecondaryWeapon.pickedUp = true
		WeaponList.SecondaryWeapon.PickedUp(Player)
		selectWeapon("secondary")
	
	if weaponCount > 1:
		pass
	weaponCount = get_child_count()
