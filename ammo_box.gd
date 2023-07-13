extends Area3D
@export var Item: PackedScene
@export var InitialCost:int = 300
var Cost = InitialCost
var Weapon
var bodyentered:bool = false
var Player
@onready var timer = $Timer

func _ready():
	Weapon = Item.instantiate()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if bodyentered:
		Player.HUD.popuplabel.visible = true
		if Player.Weapons.CurrentWeapon.name == Weapon.name:
			Cost = InitialCost / 2
			Player.HUD.popuplabel.text = "Refill {0}'s ammo for {1}$".format([Weapon.name, Cost])
			if Input.is_action_pressed("Primary Action"):
				if Input.is_action_just_pressed("Primary Action"):
					timer.start()
				elif Input.is_action_just_released("Primary Action"):
					timer.stop()
		else: 
			Cost = InitialCost
			Player.HUD.popuplabel.text = "Buy {0} for {1}$".format([Weapon.name, Cost])
	elif Player != null:
		timer.stop()
		Player.HUD.popuplabel.visible = false



func ammobox_entered(body):
	if body.has_method("ThePlayer"):
		Player = body
		bodyentered = true

func Purchase():
	pass

func itembox_exited(body):
	if body.has_method("ThePlayer"):
		Player = body
		bodyentered = false


func _on_timer_timeout():
	Purchase()
