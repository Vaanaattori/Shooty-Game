extends Node3D
@onready var body = $"."
@onready var pick_up_range = $"../../../PickUpRange"
@onready var Player = $"../../.."
@onready var weaponswap_out_dur = $"../../../Timers/WeaponSwapOutDur"
@onready var weaponswap_in_dur = $"../../../Timers/WeaponSwapInDur"
@onready var LoadM4A1 = preload("res://Entities/Guns/M4A1.tscn")
@onready var LoadGlock = preload("res://Entities/Guns/Glock.tscn")

#@export var sway_left : Vector3
@export_group("Hand Sway")
@export_range(0.01, .4) var wep_sway
@export_range(0.01,1) var ads_sway
var sway_left
var sway_right
var sway_up
var sway_down
#@export var sway_right : Vector3
var sway_normal


#@export var sway_normal : Vector3

##1 = Full sway, 0.01 = No Sway

var mouse_movX
var mouse_movY
var sway_treshold = 5
var sway_lerp = 5
var footstep_treshold = 5
var footstep_lerp = 5

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
	sway_left = Vector3(0, wep_sway, 0)
	sway_right = Vector3(0, wep_sway * -1, 0)
	sway_up = Vector3(wep_sway * .5, 0, 0)
	sway_down = Vector3((wep_sway * .5) * -1, 0, 0)
	sway_normal = rotation
	
	preloadDictionary["M4A1"] = LoadM4A1
	preloadDictionary["Glock"] = LoadGlock
	
func _input(event):
	if event is InputEventMouseMotion:
		mouse_movX = -event.relative.x
		mouse_movY = -event.relative.y
func _process(delta):
	selectWeapon("")
	if not swapping and CurrentWeapon != null:
		CurrentWeapon.PlayerAnimation = Player.animationtoplay
	if mouse_movX != null or mouse_movY != null:
		weaponSway(delta)

func weaponSway(delta):
	var SwayLeft = sway_left
	var SwayRight = sway_right
	var SwayUp = sway_up
	var SwayDown = sway_down
	if Player.ADS():
		SwayLeft = sway_left * ads_sway
		SwayRight = sway_right * ads_sway
		SwayUp = sway_up * ads_sway
		SwayDown = sway_down * ads_sway
	if mouse_movY != null:
		if mouse_movY > sway_treshold:
			rotation = rotation.lerp(SwayUp, sway_lerp * delta)
		elif mouse_movY < -sway_treshold:
			rotation = rotation.lerp(SwayDown, sway_lerp * delta)
		else:
			rotation = rotation.lerp(sway_normal, sway_lerp * delta)
	if mouse_movX != null:
		if mouse_movX > sway_treshold:
			rotation = rotation.lerp(SwayLeft, sway_lerp * delta)
		elif mouse_movX < -sway_treshold:
			rotation = rotation.lerp(SwayRight, sway_lerp * delta)
		else:
			rotation = rotation.lerp(sway_normal, sway_lerp * delta)

func walkSway():
	pass

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
