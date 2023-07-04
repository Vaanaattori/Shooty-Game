extends CanvasLayer

@onready var StaminaBar = $Label/ProgressBar
@onready var ammo_number = $AmmoContainer/AmmoNumber
@onready var total_ammo_left = $AmmoContainer/TotalAmmoLeft
@onready var crosshair = $Crosshair
@onready var PrimaryWepName = $WeaponInfo/PrimaryWeaponInfo/WeaponName



var PlayerADS = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


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
