extends CanvasLayer

@onready var StaminaBar = $Label/ProgressBar
@onready var ammo_number = $AmmoContainer/AmmoNumber
@onready var total_ammo_left = $AmmoContainer/TotalAmmoLeft
@onready var crosshair = $Crosshair
@onready var PrimaryWepName = $WeaponInfo/PrimaryWeaponInfo/WeaponName
@onready var Player = $"../"
@onready var updatetimer = $Updatetimer
@onready var debuglog = $DebugLog
@onready var weapons = $"../Neck/Camera3D/Weapons"
@onready var prianimation = $WeaponInfo/PrimaryWeaponInfo/PriAnimation
@onready var secanimation = $WeaponInfo/SecondaryWeaponInfo/SecAnimation
@onready var pri_animation_bool = $WeaponInfo/PrimaryWeaponInfo/PriAnimationBool
@onready var sec_animation_bool = $WeaponInfo/SecondaryWeaponInfo/SecAnimationBool
@onready var popuplabel = $PopUp/Label


var PlayerADS = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	StaminaBar.value = PlayerStats.stamina
	StaminaBar.max_value = PlayerStats.MaxStamina
	if weapons.CurrentWeapon != null:
		ammo_number.text = str(weapons.CurrentWeapon.WeaponStats.ammoInMag) + " / " + str(weapons.CurrentWeapon.WeaponStats.magSize)
		total_ammo_left.text = "(" + str(weapons.CurrentWeapon.WeaponStats.ammoCount) + ")"
		if Global.Player.ADS():
			crosshair.visible = false
		else: 
			crosshair.visible = true
		PrimaryWepName.text = weapons.CurrentWeapon.WeaponStats.wepName


func updatetimer_check():
#	debuglog.text = "Pose: " + str(Player.pose) + "\n" + "IsMoving: " + str(Player.isMoving) + "\n"
#	debuglog.text = "Pose: " + str(Player.pose) + "\n" + "IsMoving: " + str(Player.isMoving) + "\n" + "isADS(): " + str(Player.ADS()) + "\n" + "IsReloading: " + str(Player.Reloading) + "\n" + "AnimationPlaying: " + str(Player.animationtoplay) + "\n" + "WeaponOut: " + str(PlayerStats.weaponout)
	if weapons.weaponCount == 2:
		debuglog.text = """
		Pose: {0}
		IsMoving: {1}
		isADS(): {2}
		IsReloading: {3}
		AnimationPlaying: {4}
		WeaponOut: {5}
		CurrentWeapon: {6}
		PrimaryWeapon: {7}
		SecondaryWeapon: {8}
		Swapping: {9}
		isFiring: {10}
		""".format([Player.pose, Player.isMoving, Player.ADS(), Player.Reloading, Player.animationtoplay, weapons.CurrentWeapon, weapons.CurrentWeapon.WeaponStats.wepName, weapons.WeaponList.PrimaryWeapon.WeaponStats.wepName, weapons.WeaponList.SecondaryWeapon.WeaponStats.wepName, weapons.swapping, Player.firing])
		if weapons.WeaponList.PrimaryWeapon != null:
			if weapons.WeaponList.PrimaryWeapon.PlayerAnimation != null:
				pri_animation_bool.text = str(weapons.WeaponList.PrimaryWeapon.weaponOut)
				prianimation.text = weapons.WeaponList.PrimaryWeapon.PlayerAnimation
		if weapons.WeaponList.SecondaryWeapon != null:
			if weapons.WeaponList.SecondaryWeapon.PlayerAnimation != null:
				secanimation.text = weapons.WeaponList.SecondaryWeapon.PlayerAnimation
				sec_animation_bool.text = str(weapons.WeaponList.SecondaryWeapon.weaponOut)
#	print("Pose: ", pose, "    IsmMoving: ", isMoving, "    isADS(): ", ADS(), "    IsReloading: ", Reloading, "    AnimationPlaying: ", animationtoplay, "    WeaponOut: ", PlayerStats.weaponout)

#func PopUp(Item, Cost):

