extends CharacterBody3D

@onready var neck = $Neck
@onready var camera = $Neck/Camera3D
@onready var flashlight = $Neck/Camera3D/Flashlight
@onready var flashlight_click = $Neck/Camera3D/Flashlight/FlashlightClick
@onready var Gun = $Neck/Camera3D/M4A1
@onready var reload_animation_dur = $Timers/ReloadAnimationDur
@onready var reload_time = $Timers/ReloadTime
@onready var ads_laser = $"Neck/Camera3D/M4A1/RearSight003/ADS-Laser"
@onready var hip_fire_laser = $"Neck/Camera3D/HipFire-Laser"
@onready var playercapsule = preload("res://Entities/Player/PlayerCapsule.tres")
@onready var slidetime = $Timers/SlideTimer
@onready var slideCD = $Timers/SlideCD
@onready var slideCT = $Timers/SlideCT
@onready var Weapons = $Neck/Camera3D/Weapons
@onready var M4A1 = $Neck/Camera3D/Weapons/M4A1
@onready var weaponswap_dur = $Timers/WeaponSwapDur
@onready var gunCamera = $CanvasLayer/SubViewportContainer/SubViewport/Camera3D
@onready var HUD = $HUD
@onready var pick_up_time = $Timers/PickUpTime

#var wepName = Weapon.wepName
signal playerADS(ads)

var animationtoplay

var weaponOnGround
var firing: bool = false
var Reloading: bool = false
var exhausted: bool = false
var sliding: bool = false
var isMoving = false
var Speed = PlayerStats.BaseSpeed
var Sprint = Speed * PlayerStats.SprintMultiplier
var actualsens = PlayerStats.sensitivity  * 0.01
var isMovingcheck
var pose: String = "stand"
var JUMP_VELOCITY = 4.5
var slide_velocity = Vector3.ZERO


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
#	M4A1_animation_tree.active = true
	slidetime.wait_time = PlayerStats.SlideLength

func _unhandled_input(event):
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("ExitPause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var delta = get_physics_process_delta_time()
	if event is InputEventMouseMotion:
		if sliding:
			neck.rotate_y(-event.relative.x * actualsens * delta)
			camera.rotate_x(-event.relative.y * actualsens * delta)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-30), deg_to_rad(90))
			neck.rotation.y = clamp(neck.rotation.y, deg_to_rad(-120), deg_to_rad(120))
		else:
			rotate_y(-event.relative.x * actualsens * delta)
			neck.rotate_x(-event.relative.y * actualsens * delta)
			neck.rotation.x = clamp(neck.rotation.x, deg_to_rad(-90), deg_to_rad(90))
			
func _process(delta):
	Exhausted()
	gunCamera.global_transform = camera.global_transform
	Slide()
	if Input.is_action_just_pressed("Flashlight"):
		flashlightFunc()
	if PlayerStats.HP <= 0:
		Die()
#	if Input.is_action_just_pressed("Interact"):
#		groundPickUp()
	if Input.is_action_just_pressed("Interact"):
		pick_up_time.start()
	if not Input.is_action_pressed("Interact"):
		pick_up_time.stop()
func _physics_process(delta):
	
	if not is_on_floor():
		velocity.y -= gravity * delta
		slide_velocity.y -= gravity * delta

	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("Left", "Right", "Forwards", "Backwards")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction and not sliding:
		if Input.is_action_pressed("Sprint") and not exhausted and not Reloading:
			Pose("stand")
			PlayerStats.stamina -= delta * 5
			isMoving = "Sprint"
			Speed = Sprint
		elif pose == "stand":
			isMoving = "Walking"
			Speed = PlayerStats.BaseSpeed
			recoverStamina(1)
		elif pose == "crouch":
			isMoving = "Walking"
			Speed = PlayerStats.BaseSpeed * .5
			recoverStamina(1.25)
		elif pose == "prone":
			isMoving = "Walking"
			Speed = PlayerStats.BaseSpeed * .25
			recoverStamina(1.5)
		
		velocity.x = direction.x * Speed
		velocity.z = direction.z * Speed
	elif not sliding:
		isMoving = "Idle"
		if exhausted:
			recoverStamina(1.5)
		else:
			recoverStamina(1)
		Speed = PlayerStats.BaseSpeed
		velocity.x = move_toward(velocity.x, 0, Speed)
		velocity.z = move_toward(velocity.z, 0, Speed)

	if Input.is_action_just_pressed("Crouch") and not sliding and not isRunning():
		if pose != "crouch": Pose("crouch")
		else: Pose("stand")
	if Input.is_action_just_pressed("Prone"):
		if pose != "prone": Pose("prone")
		else: Pose("stand")
		
	move_and_slide()

func Exhausted():
	if PlayerStats.stamina <= 0:
		exhausted = true
	if PlayerStats.stamina >= PlayerStats.MaxStamina:
		exhausted = false

func recoverStamina(amount : int):
	var delta = get_process_delta_time()
	if PlayerStats.stamina < PlayerStats.MaxStamina:
		PlayerStats.stamina += amount * delta * PlayerStats.StaminaRecovery
	elif PlayerStats.stamina > PlayerStats.MaxStamina:
		PlayerStats.stamina = PlayerStats.MaxStamina

func save():
	var save_dict = {
		"filename": get_scene_file_path(),
		"parent": get_parent().get_path(),
		"pos_x": position.x,
		"pos_y": position.y,
		"pos_z": position.z,
		"MaxHP": PlayerStats.HPMax,
		"HP": PlayerStats.HP,
		"MaxStamina": PlayerStats.MaxStamina,
		"stamina": PlayerStats.stamina,
		"BaseSpeed": PlayerStats.BaseSpeed,
		"SprintMultiplier": PlayerStats.SprintMultiplier,
		"exhausted": PlayerStats.exhausted,
		"isMoving": PlayerStats.isMoving,
		"sensitivity": PlayerStats.sensitivity,
		"actualsens": PlayerStats.actualsens,
		"Speed": PlayerStats.Speed
	}
	return save_dict

func flashlightFunc():
		flashlight_click.play()
		flashlight.visible = not flashlight.visible

func Pose(value):
	pose = value
	if str(value) == "stand":
		value = 2
	if str(value) == "crouch":
		value = 1
	if str(value) == "prone":
		value = .25
	var tween = create_tween()
	tween.tween_property(playercapsule, "height", value, .2)

func ADS():
	if Input.is_action_pressed("ADS") and not Reloading and not isRunning(): return true
	else: return false

func Slide():
	var cancel = false
	if slidetime.time_left > 0 and sliding:
		if Input.is_action_just_pressed("Crouch") or Input.is_action_just_pressed("Jump") and slideCT.time_left == 0:
			on_slide_timeout()
			slidetime.stop()
			cancel = true
		velocity = slide_velocity * 1.25
		floor_max_angle = 5
	if isRunning() and Input.is_action_just_pressed("Crouch") and not sliding and not cancel and slideCD.time_left == 0:
		if slidetime.time_left == 0:
			Pose("crouch")
			PlayerStats.stamina -= 1
			slide_velocity = velocity
			sliding = true
			isMoving = "Idle"
			slidetime.start()
			slideCT.start()
	
func on_slide_timeout():
	print("timeout")
	neck.rotation.x += camera.rotation.x
	camera.rotation = Vector3.ZERO
	var oldneck = neck.rotation.y
	rotation.y += neck.rotation.y
	neck.rotation.y -= oldneck
	Pose("stand")
	isMoving == "Idle"
	sliding = false
	floor_max_angle = 45
	slideCD.start()

func isRunning():
	if Input.is_action_pressed("Sprint"):
		return true
	else:
		return false

func Die():
	$AnimationPlayer.play("Death")
#	get_tree().change_scene_to_file("res://MainMenu.tscn")

func ThePlayer():
	pass

func TakeDamage(amount):
	if $Timers/TakeDamageCD.time_left == 0:
		$Timers/TakeDamageCD.start()
		PlayerStats.HP -= amount
		print(PlayerStats.HP)

func _on_pick_up_range_body_entered(body):
	if body.has_method("Gun"):
		HUD.InteractLabel.text = "(E) Pick Up {0}".format([body.name])
		weaponOnGround = body


func _on_pick_up_range_body_exited(body):
	if body.has_method("Gun"):
		HUD.InteractLabel.text = ""
		weaponOnGround = null


func _on_pick_up_timeout():
	if weaponOnGround != null:
		Weapons.gunPickUp(weaponOnGround)
		weaponOnGround.PickUp()
