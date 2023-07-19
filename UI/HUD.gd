extends CanvasLayer

@onready var health_bar = $Control/MarginContainer/HBoxContainer/VBoxContainer/HealthContainer/HealthBar
@onready var StaminaBar = $Control/MarginContainer/HBoxContainer/VBoxContainer/StaminaContainer/StaminaBar
@onready var ammo_number = $Control/MarginContainer/HBoxContainer/AmmoContainer/AmmoNumber
@onready var total_ammo_left = $Control/MarginContainer/HBoxContainer/AmmoContainer/TotalAmmoLeft
@onready var crosshair = $Control/MarginContainer/Crosshair/CrosshairSprite
@onready var PrimaryWepName = $Control/MarginContainer/WeaponInfo/PrimaryWeaponInfo/PrimaryWeaponName
@onready var Player = $"../"
@onready var updatetimer = $Control/MarginContainer/Updatetimer
@onready var debuglog = $Control/MarginContainer/DebugLog
@onready var weapons = $"../Neck/Camera3D/Hands"
@onready var prianimation = $Control/MarginContainer/WeaponInfo/PrimaryWeaponInfo/PriAnimation
@onready var secanimation = $Control/MarginContainer/WeaponInfo/SecondaryWeaponInfo/SecAnimation
@onready var pri_animation_bool = $Control/MarginContainer/WeaponInfo/PrimaryWeaponInfo/PriAnimationBool
@onready var sec_animation_bool = $Control/MarginContainer/WeaponInfo/SecondaryWeaponInfo/SecAnimationBool
@onready var InteractLabel = $Control/MarginContainer/Crosshair/PopUp/InteractLabel
@onready var money_count = $Control/MarginContainer/HBoxContainer/VBoxContainer/MoneyCount
@onready var interact_progress_bar = $Control/MarginContainer/Crosshair/PopUp/InteractProgressBar
@onready var Error = $Control/MarginContainer/Crosshair/PopUp/InteractError

var PlayerADS = false
# Called when the node enters the scene tree for the first time.
func _ready():
	
	StaminaBar.max_value = PlayerStats.MaxStamina
	health_bar.max_value = PlayerStats.HPMax

func _process(delta):
	var interacttimer = Player.InteractTime.wait_time - Player.InteractTime.time_left
	if Player.InteractTime.time_left != 0:
		interact_progress_bar.visible = true
	else:
		interact_progress_bar.visible = false
	interact_progress_bar.max_value = Player.InteractTime.wait_time
	interact_progress_bar.value = interacttimer
	money_count.text = str(PlayerStats.money) + "$"
	StaminaBar.value = PlayerStats.stamina
	health_bar.value = PlayerStats.HP

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
	if weapons.weaponCount == 2 and not weapons.swapping:
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

