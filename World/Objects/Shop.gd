extends Area3D
@export var Item: PackedScene
@export var InitialCost:int = 300
var Cost = InitialCost
var Weapon
var bodyentered:bool = false
@onready var Player = Global.Player
var action
@onready var timer = $Timer
var Interact = Callable(self, "Action")

func _ready():
	Weapon = Item.instantiate()
	Player.connect("Interact", Interact)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if bodyentered:
		if Player.Weapons.CurrentWeapon != null:
			if Player.Weapons.CurrentWeapon.name == Weapon.name:
				Cost = InitialCost / 2
				Player.HUD.InteractLabel.text = "(E) Refill {0}'s ammo for {1}$".format([Weapon.name, Cost])
				action = "refill"
			else:
				Cost = InitialCost
				Player.HUD.InteractLabel.text = "(E) Buy {0} for {1}$".format([Weapon.name, Cost])
				action = "purchase"
		else: 
			Cost = InitialCost
			Player.HUD.InteractLabel.text = "(E) Buy {0} for {1}$".format([Weapon.name, Cost])
			action = "purchase"

func ammobox_entered(body):
	if body.has_method("ThePlayer"):
		body.HUD.InteractLabel.text = ""
		Player.HUD.Error.text = ""
		print("emter")
		Player = body
		bodyentered = true

func itembox_exited(body):
	if body.has_method("ThePlayer"):
		body.HUD.InteractLabel.text = ""
		Player.HUD.Error.text = ""
		print("left")
		Player = body
		bodyentered = false

func Action():
	if bodyentered:
		if action == "purchase" and PlayerStats.money > Cost:
			PlayerStats.money -= Cost
			Player.Weapons.gunPickUp(Weapon)
		elif action == "refill" and PlayerStats.money > Cost and not Player.Weapons.CurrentWeapon.WeaponStats.ammoCount == Player.Weapons.CurrentWeapon.WeaponStats.maxAmmo:
			PlayerStats.money -= Cost
			Player.Weapons.CurrentWeapon.WeaponStats.ammoCount = Player.Weapons.CurrentWeapon.WeaponStats.maxAmmo
		elif action == "refill" and Player.Weapons.CurrentWeapon != null and Player.Weapons.CurrentWeapon.WeaponStats.ammoCount == Player.Weapons.CurrentWeapon.WeaponStats.maxAmmo:
			Player.HUD.Error.text = "Already Max Ammo!"
		elif PlayerStats.money < Cost:
			Player.HUD.Error.text = "Not Enough Backaroos!"
