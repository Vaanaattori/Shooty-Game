extends Node3D
@onready var body = $"."
@onready var pick_up_range = $"../../../PickUpRange"
@onready var Player = $"../../.."
@onready var weaponswap_out_dur = $"../../../Timers/WeaponSwapOutDur"
@onready var weaponswap_in_dur = $"../../../Timers/WeaponSwapInDur"
@onready var LoadM4A1 = preload("res://Entities/Guns/M4A1.tscn")
@onready var LoadGlock = preload("res://Entities/Guns/Glock.tscn")
var WeaponList = {
	PrimaryWeapon = null,
	SecondaryWeapon = null,
	MeleeWeapon = null,
}
var replacing: bool = false
var preloadDictionary = {}
var CurrentWeapon = null
var SwappingTo
var SwappingFrom
var SwappingSlot
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
	if weaponCount > 0 and not swapping:
		if not CurrentWeapon.Reloading:
			if Input.is_action_just_pressed("PrimaryWep") and not CurrentWeapon == WeaponList.PrimaryWeapon and weaponCount > 1 or wep == "primary":
				WeaponSwap(WeaponList.PrimaryWeapon)
			elif Input.is_action_just_pressed("SecondaryWep") and not CurrentWeapon == WeaponList.SecondaryWeapon and weaponCount > 1 or wep == "secondary":
				WeaponSwap(WeaponList.SecondaryWeapon)
func WeaponSwap(SwappingTo):
	swapping = true
	print("Swapping From: ", CurrentWeapon," To: ", SwappingTo)
	CurrentWeapon.PlayerAnimation = "Swap-out"
	CurrentWeapon.weaponOut = false
	if replacing:
		SwappingFrom = CurrentWeapon
	CurrentWeapon = SwappingTo
	weaponswap_out_dur.start()
func weaponswap_out_timeout():
	if replacing:
		SwappingFrom.queue_free()
		add_child(CurrentWeapon)
		if SwappingSlot == "primary":
			WeaponList.PrimaryWeapon = CurrentWeapon
		elif SwappingSlot == "secondary":
			WeaponList.SecondaryWeapon = CurrentWeapon
		CurrentWeapon.PickedUp(Player)
		replacing = false
	CurrentWeapon.visible = true
	CurrentWeapon.PlayerAnimation = "Swap-in"
	CurrentWeapon.weaponOut = true
	weaponswap_in_dur.start()
func weaponswap_in_timeout():
	swapping = false
	CurrentWeapon.weaponOut = true

func gunPickUp(Gun):
	weaponCount = get_child_count()
	var gunName
	if Gun is String:
		gunName = Gun
	else:
		gunName = Gun.name

	if WeaponList.PrimaryWeapon == null:
		if preloadDictionary.has(gunName):
			# Instantiate the corresponding preloaded scene
			WeaponList.PrimaryWeapon = preloadDictionary[gunName].instantiate()
			print("Primary empty adding: ",WeaponList.PrimaryWeapon.name)
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
		if preloadDictionary.has(gunName):
			WeaponList.SecondaryWeapon = preloadDictionary[gunName].instantiate()
			add_child(WeaponList.SecondaryWeapon)
		WeaponList.SecondaryWeapon.PickedUp(Player)
		selectWeapon("secondary")
		
	else:
		if preloadDictionary.has(gunName):
			replacing = true
			SwappingTo = preloadDictionary[gunName].instantiate()
			# swapping to glock
			if CurrentWeapon == WeaponList.PrimaryWeapon:
				SwappingSlot = "primary"
				WeaponSwap(SwappingTo)
				
			else:
				SwappingSlot = "secondary"
				WeaponSwap(SwappingTo)
				
			

	if weaponCount > 1:
		pass
	weaponCount = get_child_count()
