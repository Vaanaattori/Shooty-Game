extends CharacterBody3D

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
@onready var slideCD = $Timers/SlideCD
@onready var slideCT = $Timers/SlideCT
@onready var Weapons = $Neck/Camera3D/Weapons
#var wepName = Weapon.wepName
signal playerADS(ads)


var weaponout = false
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
	animation_tree.active = true
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
		else:
			rotate_y(-event.relative.x * actualsens * delta)
			neck.rotate_x(-event.relative.y * actualsens * delta)

func _process(delta):
	if PlayerStats.weaponout == "primary" or "secondary":
		weaponout = true
	else:
		weaponout = false
	if Weapons.weaponCount > 0:
		print(PlayerStats.CurrentWeapon.wepName)
		FireRateTimer.wait_time = PlayerStats.CurrentWeapon.fireRate
	Exhausted()
	Animations()
	Shoot()
#	print("ismoving ",isMoving)
	Slide()
	if Input.is_action_just_pressed("ui_accept"):
		print(Weapons.get_child_count())
#		Weapon.add_child(M4A1)

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
	if Input.is_action_pressed("ADS") and not Reloading and not isRunning(): 
#		print("ADS true") 
		return true
	else:
#		print("ADS false") 
		return false

func Slide():
	var cancel = false
	if slidetime.time_left > 0 and sliding:
		if Input.is_action_just_pressed("Crouch") and slideCT.time_left == 0:
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

func Shoot():
	if Weapons.weaponCount > 0:
		if Input.is_action_pressed("Primary Action") and PlayerStats.CurrentWeapon.ammoInMag > 0 and not Reloading:
			if Input.is_action_just_pressed("Primary Action"):
				firing = true
				PlayerStats.CurrentWeapon.ammoInMag -= 1
				FireRateTimer.start()
		else:
			firing = false
			FireRateTimer.stop()

func Firing():
	PlayerStats.CurrentWeapon.ammoInMag -= 1

func TweenFunc(value, parameters, time):
	var tween = create_tween()
	parameters = "parameters/" + parameters + "/blend_position"
	tween.tween_property(animation_tree, parameters, value, time)

func Reload():
	var onoff = true
	
	if reload_animation_dur.time_left == 0:
#		print("reload")
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

func isRunning():
	if Input.is_action_pressed("Sprint"):
		return true
	else:
		return false

func reload_time_timeout():
	var reloadAmo = PlayerStats.CurrentWeapon.magSize - PlayerStats.CurrentWeapon.ammoInMag
	if reloadAmo >= PlayerStats.CurrentWeapon.ammoCount:
		PlayerStats.CurrentWeapon.ammoInMag += PlayerStats.CurrentWeapon.ammoCount
		PlayerStats.CurrentWeapon.ammoCount -= reloadAmo
	else:
		PlayerStats.CurrentWeapon.ammoInMag = PlayerStats.CurrentWeapon.magSize
		PlayerStats.CurrentWeapon.ammoCount -= reloadAmo

func reload_animation_dur_timeout():
	animation_tree["parameters/conditions/Reload"] = false
	Reloading = false

func Animations():
#	print("Pose: ", pose, "    IsmMoving: ", isMoving, "    isADS() ", ADS(), "    IsReloading ", Reloading)
	
	#reload
	if Input.is_action_just_pressed("Reload") and PlayerStats.CurrentWeapon.ammoCount != 0 and PlayerStats.CurrentWeapon.ammoInMag != PlayerStats.CurrentWeapon.magSize or Reloading: Reload()
	elif Input.is_action_just_pressed("Reload") and PlayerStats.CurrentWeapon.ammoCount == 0: pass

	if not Reloading and not pose == "prone":
		# Idle
		if isMoving == "Idle" and not ADS() and not firing or sliding and not ADS() and not firing:
#			print("idle")
			animation_tree["parameters/conditions/HipFire"] = false
			animation_tree["parameters/conditions/ADS_Firing"] = false
			animation_tree["parameters/conditions/Idle"] = true
			animation_tree["parameters/conditions/Walking"] = false
			animation_tree["parameters/conditions/Sprint"] = false
			animation_tree["parameters/conditions/ADS"] = false
			animation_tree["parameters/conditions/Crawl"] = false

		# Walking
		if isMoving == "Walking" and not ADS() and not firing and not sliding:
#			print("walking")
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
		if ADS() and not isRunning() or ADS() and sliding:
#			print("ads")
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
		if isRunning() and pose == "stand" and not sliding:
#				print("sprinting")
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
#		print("prone")
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

func _on_pick_up_range_body_entered(body):
	body = body.get_owner()
	print(body)
	if body.has_method("Gun"):
		if Weapons.get_child_count() == 0:
			print("picking up gun")
			Weapons.gunPickUp(body)
		body.PickUp()
