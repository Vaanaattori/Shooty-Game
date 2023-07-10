extends Node3D
@onready var body = $"."
@onready var pick_up_range = $"../../../PickUpRange"
@onready var Player = $"../../.."
@onready var weaponswap_out_dur = $"../../../Timers/WeaponSwapOutDur"
@onready var weaponswap_in_dur = $"../../../Timers/WeaponSwapInDur"

var WeaponSelected
var PrimaryWeapon
var SecondaryWeapon
var MeleeWeapon
var swapping:bool = false
var weaponCount = get_child_count()

func _ready():
	pass
	
func _process(delta):
	selectWeapon("")
	if not swapping and WeaponSelected != null:
		WeaponSelected.PlayerAnimation = Player.animationtoplay
func selectWeapon(wep):
	#when primary selected
	if not Player.Reloading:
		if Input.is_action_just_pressed("PrimaryWep") and not WeaponSelected == PrimaryWeapon and weaponCount > 1 or wep == "primary":
			swapping = true
			print(WeaponSelected)
			WeaponSelected.PlayerAnimation = "Swap-out"
			WeaponSelected.weaponOut = false
			print(WeaponSelected.PlayerAnimation)
			WeaponSelected = PrimaryWeapon
			weaponswap_out_dur.start()

		if Input.is_action_just_pressed("SecondaryWep") and not WeaponSelected == SecondaryWeapon and weaponCount > 1 or wep == "secondary":
			swapping = true
			print(WeaponSelected)
			WeaponSelected.PlayerAnimation = "Swap-out"
			WeaponSelected.weaponOut = false
			print(WeaponSelected.PlayerAnimation)
			WeaponSelected = SecondaryWeapon
			weaponswap_out_dur.start()

func weaponswap_out_timeout():
	if WeaponSelected == PrimaryWeapon:
		if WeaponSelected.animation_tree.active != true:
			WeaponSelected.animation_tree.active = true
		else:
			WeaponSelected.PlayerAnimation = "Swap-in"
		weaponswap_in_dur.start()
	if WeaponSelected == SecondaryWeapon:
		if WeaponSelected.animation_tree.active != true:
			WeaponSelected.animation_tree.active = true
		else:
			WeaponSelected.PlayerAnimation = "Swap-in"
		weaponswap_in_dur.start()

func weaponswap_in_timeout():
	swapping = false
	if WeaponSelected == PrimaryWeapon:
		WeaponSelected.weaponOut = true
		PlayerStats.weaponout = "primary"
	if WeaponSelected == SecondaryWeapon:
		WeaponSelected.weaponOut = true
		PlayerStats.weaponout = "secondary"

func gunPickUp(Gun):
	weaponCount = get_child_count()
	if weaponCount == 0:
		print("Picked up: ",Gun.name)
		Gun = load("res://Guns/" + str(Gun.name) + ".tscn")
		PrimaryWeapon = Gun.instantiate()
		add_child(PrimaryWeapon)
		WeaponSelected = PrimaryWeapon
		WeaponSelected.pickedUp = true
		WeaponSelected.PickedUp()
#		PlayerStats.PrimaryWeapon = PrimaryWeapon.WeaponStats
		WeaponSelected.Player = Player
		WeaponSelected.weaponOut = true
		WeaponSelected.animation_tree.active = true
		WeaponSelected.PlayerAnimation = "Swap-in"
		print(WeaponSelected.PlayerAnimation)
		weaponswap_in_dur.start()
	
	if weaponCount == 1:
		print("Picked up: ",Gun.name)
		Gun = load("res://Guns/" + str(Gun.name) + ".tscn")
		SecondaryWeapon = Gun.instantiate()
		add_child(SecondaryWeapon)
		SecondaryWeapon.pickedUp = true
		SecondaryWeapon.Player = Player
		SecondaryWeapon.PickedUp()
#		PlayerStats.SecondaryWeapon = SecondaryWeapon.WeaponStats
		selectWeapon("secondary")
	
	weaponCount = get_child_count()







