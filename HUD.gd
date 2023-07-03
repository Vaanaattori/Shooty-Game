extends CanvasLayer

@onready var StaminaBar = $Label/ProgressBar
@onready var ammo_number = $AmmoContainer/AmmoNumber
@onready var total_ammo_left = $AmmoContainer/TotalAmmoLeft
@onready var crosshair = $Crosshair

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	StaminaBar.value = Player.stamina
	StaminaBar.max_value = Player.MaxStamina
	ammo_number.text = str(Player.ammoInMag) + " / " + str(Player.magSize)
	total_ammo_left.text = "(" + str(Player.ammoCount) + ")"
	if Player.ADS(): 
		crosshair.visible = false
	else: 
		crosshair.visible = true
