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


var PlayerADS = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	StaminaBar.value = PlayerStats.stamina
	StaminaBar.max_value = PlayerStats.MaxStamina
	ammo_number.text = str(PlayerStats.CurrentWeapon.ammoInMag) + " / " + str(PlayerStats.CurrentWeapon.magSize)
	total_ammo_left.text = "(" + str(PlayerStats.CurrentWeapon.ammoCount) + ")"
	if Global.Player.ADS():
		crosshair.visible = false
	else: 
		crosshair.visible = true
	PrimaryWepName.text = PlayerStats.CurrentWeapon.wepName


func updatetimer_check():
#	debuglog.text = "Pose: " + str(Player.pose) + "\n" + "IsMoving: " + str(Player.isMoving) + "\n"
#	debuglog.text = "Pose: " + str(Player.pose) + "\n" + "IsMoving: " + str(Player.isMoving) + "\n" + "isADS(): " + str(Player.ADS()) + "\n" + "IsReloading: " + str(Player.Reloading) + "\n" + "AnimationPlaying: " + str(Player.animationtoplay) + "\n" + "WeaponOut: " + str(PlayerStats.weaponout)
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
	""".format([Player.pose, Player.isMoving, Player.ADS(), Player.Reloading, Player.animationtoplay, weapons.WeaponSelected, PlayerStats.CurrentWeapon.wepName, PlayerStats.PrimaryWeapon.wepName, PlayerStats.SecondaryWeapon.wepName])
	if weapons.PrimaryWeapon != null:
		if weapons.PrimaryWeapon.PlayerAnimation != null:
			prianimation.text = weapons.PrimaryWeapon.PlayerAnimation
	if weapons.SecondaryWeapon != null:
		if weapons.SecondaryWeapon.PlayerAnimation != null:
			secanimation.text = weapons.SecondaryWeapon.PlayerAnimation
#	print("Pose: ", pose, "    IsmMoving: ", isMoving, "    isADS(): ", ADS(), "    IsReloading: ", Reloading, "    AnimationPlaying: ", animationtoplay, "    WeaponOut: ", PlayerStats.weaponout)
