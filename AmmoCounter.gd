extends MeshInstance3D
@export var ammo_label = Label3D
@export var gun = RigidBody3D

func _ready():
	ammo_label.modulate = Color(0, 255, 0, 65)

func _process(delta):
	ammo_label.visible = true
	ammo_label.text = str(gun.WeaponStats.ammoInMag)
	if gun.pickedUp:
		set_layer_mask_value(1, false)
		set_layer_mask_value(2, true)
	else:
		set_layer_mask_value(1, true)
		set_layer_mask_value(2, false)
	if gun.halfAmmo > gun.WeaponStats.ammoCount:
		#green
		ammo_label.modulate = Color(255, 125, 0, 100)
	elif gun.WeaponStats.ammoCount == 0:
		#red
		ammo_label.modulate = Color(255, 0, 0, 100)
