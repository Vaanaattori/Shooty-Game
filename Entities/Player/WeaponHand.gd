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
	if weaponCount > 0:
		if not WeaponSelected.Reloading and not swapping:
			if Input.is_action_just_pressed("PrimaryWep") and not WeaponSelected == PrimaryWeapon and weaponCount > 1 or wep == "primary":
				swapping = true
				print(WeaponSelected)
				WeaponSelected.PlayerAnimation = "Swap-out"
				WeaponSelected.weaponOut = false
				WeaponSelected = PrimaryWeapon
				weaponswap_out_dur.start()
			elif Input.is_action_just_pressed("SecondaryWep") and not WeaponSelected == SecondaryWeapon and weaponCount > 1 or wep == "secondary":
				swapping = true
	#			print("test: ",WeaponSelected)
				WeaponSelected.PlayerAnimation = "Swap-out"
				WeaponSelected.weaponOut = false
				WeaponSelected = SecondaryWeapon
				weaponswap_out_dur.start()
func weaponswap_out_timeout():
	if WeaponSelected == PrimaryWeapon:
		if WeaponSelected.animation_tree.active != true:
			WeaponSelected.animation_tree.active = true
			WeaponSelected.PlayerAnimation = "Swap-in"
		else:
			WeaponSelected.PlayerAnimation = "Swap-in"
		WeaponSelected.weaponOut = true
		weaponswap_in_dur.start()
	if WeaponSelected == SecondaryWeapon:
		if WeaponSelected.animation_tree.active != true:
			WeaponSelected.animation_tree.active = true
			WeaponSelected.PlayerAnimation = "Swap-in"
		else:
			WeaponSelected.PlayerAnimation = "Swap-in"
		WeaponSelected.weaponOut = true
		weaponswap_in_dur.start()

func weaponswap_in_timeout():
	swapping = false
	WeaponSelected.weaponOut = true

func gunPickUp(Gun):
	weaponCount = get_child_count()
	if weaponCount == 0:
		print("Picked up: ",Gun.name)
		Gun = load("res://Guns/" + str(Gun.name) + ".tscn")
		PrimaryWeapon = Gun.instantiate()
		add_child(PrimaryWeapon)
		PrimaryWeapon.pickedUp = true
		PrimaryWeapon.PickedUp()
		WeaponSelected = PrimaryWeapon
		WeaponSelected.Player = Player
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
		selectWeapon("secondary")
	
	if weaponCount > 1:
		pass
	weaponCount = get_child_count()
