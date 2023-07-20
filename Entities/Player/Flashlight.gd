extends SpotLight3D

@onready var CooldownTimer = $CooldownTimer
@onready var DurationTimer = $DurationTimer
@onready var stun_area = $StunArea

@export var Charges:int = 5
@export var Duration:int = 2
@export var CoolDown:int = 3
@export var Strength:int = 4

var Flashing:bool = false

func _ready():
	CooldownTimer.wait_time = CoolDown
	DurationTimer.wait_time = Duration

func _process(delta):
	if Input.is_action_just_pressed("Flashlight") and CooldownTimer.time_left == 0:
		Flash()
	
	if Flashing:
		visible = true
		for Body in stun_area.get_overlapping_bodies():
			if Body.has_method("Enemy"):
				if not Body.Stunned:
					Body.Stun(Strength)
	else:
		visible = false

func Flash():
	Charges -= 1
	DurationTimer.start()
	Flashing = true

func Duration_Timeout():
	CooldownTimer.start()
	Flashing = false
