extends Node3D
@export var hand_animations: AnimationPlayer
@onready var body = $"."
@onready var pick_up_range = $"../../../../PickUpRange"
@onready var Player = $"../../../.."
@onready var weaponswap_out_dur = $"../../../../Timers/WeaponSwapOutDur"
@onready var weaponswap_in_dur = $"../../../../Timers/WeaponSwapInDur"
@onready var LoadM4A1 = preload("res://Entities/Guns/M4A1.tscn")
@onready var LoadMP5 = preload("res://Entities/Guns/MP5.tscn")
@onready var LoadGlock = preload("res://Entities/Guns/Glock.tscn")

@export var swapping:bool = false
@export_group("Hand Sway")
@export_range(0.01, .4) var wep_sway
@export_range(0.01,1) var ads_sway

var sway_left
var sway_right
var sway_up
var sway_down
var sway_normal

var mouse_movX
var mouse_movY
var sway_treshold = 5
var sway_lerp = 5

var WeaponList = {
	PrimaryWeapon = null,
	SecondaryWeapon = null,
	MeleeWeapon = null,
}

var replacing: bool = false
@export var preloadDictionary = {
	Weapon1 = "",
}
var CurrentWeapon = null
var SwappingTo
var SwappingFrom
var SwappingSlot
var weaponCount = get_child_count()
var PlayOnce: bool = false

func _ready():
	sway_left = Vector3(0, wep_sway, 0)
	sway_right = Vector3(0, wep_sway * -1, 0)
	sway_up = Vector3(wep_sway * .5, 0, 0)
	sway_down = Vector3((wep_sway * .5) * -1, 0, 0)
	sway_normal = rotation
	preloadDictionary["M4A1"] = LoadM4A1
	preloadDictionary["Glock"] = LoadGlock
	preloadDictionary["MP5"] = LoadMP5

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
	if not swapping:
		if not Player.isMoving == "Idle" and not Player.ADS():
			hand_animations.play("Walk")
			hand_animations.speed_scale = Player.Speed / 2
			PlayOnce = false
		elif Player.isMoving == "Idle" and not Player.ADS():
			hand_animations.play("Idle")
			PlayOnce = false
		if Player.ADS() and Player.isMoving == "Idle":
			hand_animations.play("ADS")
		elif Player.ADS():
			hand_animations.play("ADS_Walk")
	else:
		hand_animations.speed_scale = 1
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
		if not Player.Reloading:
			if Input.is_action_just_pressed("PrimaryWep") and not CurrentWeapon == WeaponList.PrimaryWeapon and weaponCount > 1 or wep == "primary":
				WeaponSwap(WeaponList.PrimaryWeapon)
			elif Input.is_action_just_pressed("SecondaryWep") and not CurrentWeapon == WeaponList.SecondaryWeapon and weaponCount > 2 or wep == "secondary":
				WeaponSwap(WeaponList.SecondaryWeapon)

func WeaponSwap(SwappingTo):
	SwappingFrom = CurrentWeapon
	if SwappingTo != null:
		CurrentWeapon = SwappingTo
	print("Swapping From: ", SwappingFrom," To: ", CurrentWeapon)
	SwappingFrom.weaponOut = false
	SwappingFrom.visible = true
	CurrentWeapon.visible = false
	swapping = true
	hand_animations.stop()
	hand_animations.play("Swap-Out")

func Swapping_Out():
	if replacing:
		SwappingFrom.queue_free()
		add_child(CurrentWeapon)
		if SwappingSlot == "primary":
			WeaponList.PrimaryWeapon = CurrentWeapon
		elif SwappingSlot == "secondary":
			WeaponList.SecondaryWeapon = CurrentWeapon
		CurrentWeapon.PickedUp()
		replacing = false
	SwappingFrom.visible = false
	CurrentWeapon.visible = true
	hand_animations.play("Swap-In")

func Swapped_In():
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
		if Global.WeaponList.has(gunName):
			WeaponList.PrimaryWeapon = Global.WeaponList[gunName].instantiate()
			print("Primary empty adding: ",WeaponList.PrimaryWeapon.name)
			add_child(WeaponList.PrimaryWeapon)
			WeaponList.PrimaryWeapon.PickedUp()
			if CurrentWeapon == null:
				CurrentWeapon = WeaponList.PrimaryWeapon
				CurrentWeapon.visible = true
				hand_animations.play("Swap-In")
			else:
				selectWeapon("primary")
		else:
			print(gunName, " Does not exist in preloadDictionary")
	
	elif WeaponList.SecondaryWeapon == null:
		if Global.WeaponList.has(gunName):
			WeaponList.SecondaryWeapon = Global.WeaponList[gunName].instantiate()
			add_child(WeaponList.SecondaryWeapon)
		WeaponList.SecondaryWeapon.PickedUp()
		selectWeapon("secondary")
		
	else:
		if Global.WeaponList.has(gunName):
			replacing = true
			SwappingTo = Global.WeaponList[gunName].instantiate()
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
