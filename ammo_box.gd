extends Area3D
@export var Item: PackedScene
@export var Cost:int = 300
var Weapon
var bodyentered:bool = false
var Player
func _ready():
	Weapon = Item.instantiate()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if bodyentered:
		Player.HUD.popuplabel.visible = true
		if Player.Weapons.WeaponSelected.name == Weapon.name:
			var HalfCost = Cost / 2
			Player.HUD.popuplabel.text = "Refill {0}'s ammo for {1}$".format([Weapon.name, HalfCost])
		else: 
			Player.HUD.popuplabel.text = "Buy {0} for {1}$".format([Weapon.name, Cost])
	elif Player != null:
		Player.HUD.popuplabel.visible = false



func ammobox_entered(body):
	if body.has_method("ThePlayer"):
		Player = body
		bodyentered = true


func itembox_exited(body):
	if body.has_method("ThePlayer"):
		Player = body
		bodyentered = false
