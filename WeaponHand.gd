extends Node3D
@onready var body = $"."
@onready var pick_up_range = $"../../../PickUpRange"
@onready var Player = $"../../.."
var WeaponInHand
var weaponCount = get_child_count()

func _ready():
	pass
	
func _process(delta):
	if weaponCount > 0:
		WeaponInHand.PlayerAnimation = Player.animationtoplay

func gunPickUp(Gun):
	print("Picked up: ",Gun.name)
	Gun = load("res://Guns/" + str(Gun.name) + ".tscn")
	WeaponInHand = Gun.instantiate()
	add_child(WeaponInHand)
	WeaponInHand.pickedUp = true
	WeaponInHand.PickedUp()
	PlayerStats.PrimaryWeapon = WeaponInHand.WeaponStats
	PlayerStats.weaponout = "primary"
	print(get_child(0))
	weaponCount = get_child_count()

