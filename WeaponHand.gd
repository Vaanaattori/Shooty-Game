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
var inanimation:bool = false
var weaponCount = get_child_count()

func _ready():
	pass
	
func _process(delta):
	selectWeapon()
	if not inanimation and WeaponSelected != null:
		WeaponSelected.PlayerAnimation = Player.animationtoplay
func selectWeapon():
	#when primary selected
	if Input.is_action_just_pressed("PrimaryWep") and not PlayerStats.weaponout == "primary" and weaponCount > 1:
#		WeaponSelected.PlayerAnimation = "Swap-out"
		print("test")
		inanimation = true
		WeaponSelected = PrimaryWeapon
		weaponswap_out_dur.start()

	if Input.is_action_just_pressed("SecondaryWep") and not PlayerStats.weaponout == "secondary" and weaponCount > 1:
		inanimation = true
		WeaponSelected.PlayerAnimation = "Swap-out"
		WeaponSelected = SecondaryWeapon
		weaponswap_out_dur.start()

func weaponswap_out_timeout():
	if WeaponSelected == PrimaryWeapon:
		WeaponSelected.PlayerAnimation = "Swap-in"
		weaponswap_in_dur.start()
	if WeaponSelected == SecondaryWeapon:
		WeaponSelected.PlayerAnimation = "Swap-in"
		weaponswap_in_dur.start()

func weaponswap_in_timeout():
	inanimation = false
	if WeaponSelected == PrimaryWeapon:
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
		PlayerStats.PrimaryWeapon = PrimaryWeapon.WeaponStats
		PlayerStats.weaponout = "primary"
		WeaponSelected = PrimaryWeapon
		WeaponSelected.PlayerAnimation = Player.animationtoplay
		print(get_child(0))
	
	if weaponCount == 1:
		print("Picked up: ",Gun.name)
		Gun = load("res://Guns/" + str(Gun.name) + ".tscn")
		SecondaryWeapon = Gun.instantiate()
		add_child(SecondaryWeapon)
		SecondaryWeapon.pickedUp = true
		SecondaryWeapon.PickedUp()
		PlayerStats.SecondaryWeapon = SecondaryWeapon.WeaponStats
		PlayerStats.weaponout = "secondary"
		WeaponSelected = SecondaryWeapon
		print(get_child(1))
	
	weaponCount = get_child_count()







