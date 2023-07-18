extends Area3D
@export var Item: PackedScene
@export var InitialCost:int = 300
var Cost = InitialCost
var Weapon
var bodyentered:bool = false
var Player
var action
@onready var timer = $Timer

func _ready():
	Weapon = Item.instantiate()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if bodyentered:
		if Player.Weapons.CurrentWeapon != null:
			if Player.Weapons.CurrentWeapon.name == Weapon.name:
				Refill()
			else:
				Purchase()
		else: 
			Purchase()
	elif Player != null:
		timer.stop()

func ammobox_entered(body):
	if body.has_method("ThePlayer"):
		body.HUD.InteractLabel.text = ""
		print("emter")
		Player = body
		bodyentered = true

func itembox_exited(body):
	if body.has_method("ThePlayer"):
		body.HUD.InteractLabel.text = ""
		print("left")
		Player = body
		bodyentered = false

func Purchase():
	Cost = InitialCost
	Player.HUD.InteractLabel.text = "(E) Buy {0} for {1}$".format([Weapon.name, Cost])
	if Input.is_action_just_pressed("Interact") and PlayerStats.money > Cost:
		timer.start()
		action = "purchase"
	if  not Input.is_action_pressed("Interact"):
		timer.stop()

func Refill():
	Cost = InitialCost / 2
	Player.HUD.InteractLabel.text = "(E) Refill {0}'s ammo for {1}$".format([Weapon.name, Cost])
	if Input.is_action_just_pressed("Interact") and PlayerStats.money > Cost and not Player.Weapons.CurrentWeapon.WeaponStats.ammoCount == Player.Weapons.CurrentWeapon.WeaponStats.maxAmmo:
		timer.start()
		action = "refill"
	if  not Input.is_action_pressed("Interact"):
		timer.stop()

func _on_timer_timeout():
	if action == "purchase":
		PlayerStats.money -= Cost
		Player.Weapons.gunPickUp(Weapon)
	elif action == "refill":
		PlayerStats.money -= Cost
		Player.Weapons.CurrentWeapon.WeaponStats.ammoCount = Player.Weapons.CurrentWeapon.WeaponStats.maxAmmo
