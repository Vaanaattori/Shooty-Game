extends CharacterBody3D

@export_group("Stats")
@export var HPMax = 100
@export var HP = 100
@export var MaxStamina = 25
@export var stamina = 200
@export var BaseSpeed = 4
@export var SprintMultiplier = 2
@export var ammoCount = 999
@export var magSize = 30
@export var FireRate = 0.1
@export var StaminaRecovery = 10
@export var SlideLength = 1.25

@export_group("Settings")
@export var sensitivity = 10

var firing: bool = false
var Reloading: bool = false
var exhausted: bool = false
var sliding: bool = false
var isMoving = false
var Speed = BaseSpeed
var Sprint = Speed * SprintMultiplier
var actualsens = sensitivity  * 0.01
var isMovingcheck
var ammoInMag = magSize
var pose: String = "stand"
var JUMP_VELOCITY = 4.5
var slide_velocity = Vector3.ZERO
@onready var neck = $Neck
@onready var camera = $Neck/Camera3D
@onready var flashlight = $Neck/Camera3D/Flashlight
@onready var flashlight_click = $Neck/Camera3D/Flashlight/FlashlightClick
@onready var Gun = $Neck/Camera3D/M4A1
@onready var animation_tree = $AnimationTree
@onready var reload_animation_dur = $Timers/ReloadAnimationDur
@onready var reload_time = $Timers/ReloadTime
@onready var ads_laser = $"Neck/Camera3D/M4A1/RearSight003/ADS-Laser"
@onready var hip_fire_laser = $"Neck/Camera3D/HipFire-Laser"
@onready var playercapsule = preload("res://PlayerCapsule.tres")
@onready var FireRateTimer = $Timers/FireRate
@onready var slidetime = $Timers/SlideTimer


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	animation_tree.active = true
	FireRateTimer.wait_time = FireRate
	slidetime.wait_time = SlideLength

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
		else:
			rotate_y(-event.relative.x * actualsens * delta)
			neck.rotate_x(-event.relative.y * actualsens * delta)

func _process(delta):
	Exhausted()
	Animations()
	Shoot()
	print(isMoving)
	Slide()

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
			stamina -= delta * 5
			isMoving = "Sprint"
			Speed = Sprint
		elif pose == "stand":
			isMoving = "Walking"
			Speed = BaseSpeed
			recoverStamina(1)
		elif pose == "crouch":
			isMoving = "Walking"
			Speed = BaseSpeed * .5
			recoverStamina(1.25)
		elif pose == "prone":
			isMoving = "Walking"
			Speed = BaseSpeed * .25
			recoverStamina(1.5)
		
		velocity.x = direction.x * Speed
		velocity.z = direction.z * Speed
	elif not sliding:
		isMoving = "Idle"
		if exhausted:
			recoverStamina(1.5)
		else:
			recoverStamina(1)
		Speed = BaseSpeed
		velocity.x = move_toward(velocity.x, 0, Speed)
		velocity.z = move_toward(velocity.z, 0, Speed)

	if Input.is_action_just_pressed("Crouch") and not sliding:
		if pose != "crouch": Pose("crouch")
		else: Pose("stand")
	if Input.is_action_just_pressed("Prone"):
		if pose != "prone": Pose("prone")
		else: Pose("stand")
		
	move_and_slide()

func Exhausted():
	if stamina <= 0:
		exhausted = true
	if stamina >= MaxStamina:
		exhausted = false

func recoverStamina(amount : int):
	var delta = get_process_delta_time()
	if stamina < MaxStamina:
		stamina += amount * delta * StaminaRecovery
	elif stamina > MaxStamina:
		stamina = MaxStamina

func save():
	var save_dict = {
		"filename": get_scene_file_path(),
		"parent": get_parent().get_path(),
		"pos_x": position.x,
		"pos_y": position.y,
		"pos_z": position.z,
		"MaxHP": HPMax,
		"HP": HP,
		"MaxStamina": MaxStamina,
		"stamina": stamina,
		"BaseSpeed": BaseSpeed,
		"SprintMultiplier": SprintMultiplier,
		"exhausted": exhausted,
		"isMoving": isMoving,
		"sensitivity": sensitivity,
		"actualsens": actualsens,
		"Speed": Speed
	}
	return save_dict

func flashlightFunc():
	if Input.is_action_just_pressed("Flashlight"):
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
	if Input.is_action_pressed("ADS"): return true
	else: return false

func Slide():
	if slidetime.time_left > 0 and sliding:
		velocity = slide_velocity * 1.25
	if isMoving == "Sprint" and Input.is_action_just_pressed("Crouch") and not sliding:
		if slidetime.time_left == 0:
			Pose("crouch")
			stamina -= 1
			slide_velocity = velocity
			sliding = true
			slidetime.start()
	
func on_slide_timeout():
	sliding = false
	neck.rotation.x += camera.rotation.x
	camera.rotation = Vector3.ZERO
	var oldneck = neck.rotation.y
	rotation.y += neck.rotation.y
	neck.rotation.y -= oldneck
	Pose("stand")
	

func Shoot():
	if Input.is_action_pressed("Primary Action") and ammoInMag > 0 and not Reloading:
		if Input.is_action_just_pressed("Primary Action"):
			firing = true
			ammoInMag -= 1
			FireRateTimer.start()
	else:
		firing = false
		FireRateTimer.stop()

func Firing():
	ammoInMag -= 1

func TweenFunc(value, parameters, time):
	var tween = create_tween()
	parameters = "parameters/" + parameters + "/blend_position"
	tween.tween_property(animation_tree, parameters, value, time)

func Reload():
	var onoff = true
	
	if reload_animation_dur.time_left == 0:
		print("reload")
		Reloading = true
		animation_tree["parameters/conditions/Idle"] = false
		animation_tree["parameters/conditions/Walking"] = false
		animation_tree["parameters/conditions/Sprint"] = false
		animation_tree["parameters/conditions/ADS"] = false
		animation_tree["parameters/conditions/HipFire"] = false
		animation_tree["parameters/conditions/Crawl"] = false
		animation_tree["parameters/conditions/Reload"] = true
		reload_animation_dur.start()
		reload_time.start()
		# I HAVE 60 bullets left
		# I have 29 in mag
		# 30 - 29 = 1 reloadamount
		# 60 - 1 = 59 bullets left
		# If ammo left < mag size ( ammo left 15 )
		# ammoinmag + 15
		# 15

func reload_time_timeout():
	var reloadAmo = magSize - ammoInMag
	if reloadAmo >= ammoCount:
		ammoInMag += ammoCount
		ammoCount -= reloadAmo
	else:
		ammoInMag = magSize
		ammoCount -= reloadAmo

func reload_animation_dur_timeout():
	animation_tree["parameters/conditions/Reload"] = false
	Reloading = false

func Animations():
#	print("Pose: ", pose, "    IsmMoving: ", isMoving, "    isADS() ", ADS(), "    IsReloading ", Reloading)
	
	#reload
	if Input.is_action_just_pressed("Reload")and ammoCount != 0 and ammoInMag != magSize or Reloading: Reload()
	elif Input.is_action_just_pressed("Reload") and ammoCount == 0: pass

	if not Reloading and not pose == "prone":
		# Idle
		if isMoving == "Idle" and not ADS() and not firing or sliding and not ADS() and not firing:
			animation_tree["parameters/conditions/HipFire"] = false
			animation_tree["parameters/conditions/ADS_Firing"] = false
			animation_tree["parameters/conditions/Idle"] = true
			animation_tree["parameters/conditions/Walking"] = false
			animation_tree["parameters/conditions/Sprint"] = false
			animation_tree["parameters/conditions/ADS"] = false
			animation_tree["parameters/conditions/Crawl"] = false

		# Walking
		if isMoving == "Walkin	g" and not ADS() and not firing and not sliding:
			animation_tree["parameters/conditions/HipFire"] = false
			animation_tree["parameters/conditions/ADS_Firing"] = false
			animation_tree["parameters/conditions/Idle"] = false
			animation_tree["parameters/conditions/Walking"] = true
			animation_tree["parameters/conditions/Sprint"] = false
			animation_tree["parameters/conditions/ADS"] = false
			animation_tree["parameters/conditions/Crawl"] = false
			if pose == "crouch":
				TweenFunc(-1, "Walk", .1)
			else:
				TweenFunc(1, "Walk", .1)
		
		# ADS
		if ADS() and isMoving != "Sprint" or ADS() and sliding:
			if firing:
				animation_tree["parameters/conditions/ADS_Firing"] = true
				animation_tree["parameters/conditions/ADS"] = false
			else:
				animation_tree["parameters/conditions/ADS_Firing"] = false
				animation_tree["parameters/conditions/ADS"] = true
			animation_tree["parameters/conditions/HipFire"] = false
			animation_tree["parameters/conditions/Idle"] = false
			animation_tree["parameters/conditions/Walking"] = false
			animation_tree["parameters/conditions/Sprint"] = false
			animation_tree["parameters/conditions/Crawl"] = false
			if isMovingcheck != isMoving:
				if isMoving == "Walking": 
					TweenFunc(10, "ADS", .1)
				elif isMoving == "Idle": 
					TweenFunc(0, "ADS", .1)
			isMovingcheck = isMoving

		# Sprinting
		if isMoving == "Sprint" and pose == "stand" and not sliding:
				animation_tree["parameters/conditions/HipFire"] = false
				animation_tree["parameters/conditions/ADS_Firing"] = false
				animation_tree["parameters/conditions/ADS"] = false
				animation_tree["parameters/conditions/Idle"] = false
				animation_tree["parameters/conditions/Walking"] = false
				animation_tree["parameters/conditions/Crawl"] = false
				animation_tree["parameters/conditions/Sprint"] = true
	# end of "if not Reloading and not pose == "prone"
	# Prone
	if pose == "prone" and not Reloading:
		animation_tree["parameters/conditions/HipFire"] = false
		animation_tree["parameters/conditions/ADS_Firing"] = false
		animation_tree["parameters/conditions/ADS"] = false
		animation_tree["parameters/conditions/Idle"] = false
		animation_tree["parameters/conditions/Walking"] = false
		animation_tree["parameters/conditions/Sprint"] = false
		animation_tree["parameters/conditions/Crawl"] = true

	# Hipfire
	if firing and not ADS() and not Reloading:
		animation_tree["parameters/conditions/Sprint"] = false
		animation_tree["parameters/conditions/HipFire"] = true
		animation_tree["parameters/conditions/ADS_Firing"] = false
		animation_tree["parameters/conditions/ADS"] = false
		animation_tree["parameters/conditions/Idle"] = false
		animation_tree["parameters/conditions/Walking"] = false
		

func ThePlayer():
	pass



