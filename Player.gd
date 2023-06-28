extends CharacterBody3D

@export var MaxHealth = 100
@export var Health = 100
@export var MaxStamina = 25
@export var stamina = 25
@export var BaseSpeed = 4
@export var SprintMultiplier = 2
var exhausted : bool = false
var isMoving : bool = false
@export var sensitivity = 10
var actualsens = sensitivity  * 0.01
var Speed = BaseSpeed
var test = "12345"
var JUMP_VELOCITY = 4.5
@onready var camera = $Camera3D 
@onready var camera_3d = $Camera3D
@onready var pause_menu = $"Pause Menu"
@onready var flashlight = $Camera3D/Flashlight
@onready var flashlight_click = $Camera3D/Flashlight/FlashlightClick
@onready var can_jump = $CanJump
@onready var Gun = $Camera3D/M4A1


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _unhandled_input(event):
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("ExitPause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var delta = get_physics_process_delta_time()
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * actualsens * delta)
		camera.rotate_x(-event.relative.y * actualsens * delta)

func _process(delta):
	staminaFunc(delta)
	flashlightFunc()
	ADS()

func _physics_process(delta):
	
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("Left", "Right", "Forwards", "Backwards")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		isMoving = true
		velocity.x = direction.x * Speed
		velocity.z = direction.z * Speed
	else:
		isMoving = false
		velocity.x = move_toward(velocity.x, 0, Speed)
		velocity.z = move_toward(velocity.z, 0, Speed)

	move_and_slide()

func staminaFunc(delta):
	Exhausted()
	if Input.is_action_pressed("Sprint") and not exhausted and isMoving:
		stamina -= delta * 10
		print(stamina)
		if Input.is_action_just_pressed("Sprint"):
			Speed *= SprintMultiplier
			print("zoomies")
	if not Input.is_action_pressed("Sprint") or exhausted or not isMoving:
		if exhausted:
			recoverStamina(1.5)
		else:
			recoverStamina(1)
		Speed = BaseSpeed

func Exhausted():
	if stamina <= 0:
		exhausted = true
	if stamina >= MaxStamina:
		exhausted = false

func recoverStamina(amount : int):
	var delta = get_process_delta_time()
	if stamina < MaxStamina:
		stamina += amount * delta * 2.5
	elif stamina > MaxStamina:
		stamina = MaxStamina

func save():
	var save_dict = {
		"filename": get_scene_file_path(),
		"parent": get_parent().get_path(),
		"pos_x": position.x,
		"pos_y": position.y,
		"pos_z": position.z,
		"MaxHP": MaxHealth,
		"HP": Health,
		"MaxStamina": MaxStamina,
		"stamina": stamina,
		"BaseSpeed": BaseSpeed,
		"SprintMultiplier": SprintMultiplier,
		"exhausted": exhausted,
		"isMoving": isMoving,
		"sensitivity": sensitivity,
		"actualsens": actualsens,
		"Speed": Speed,
		"Test": test
	}
	return save_dict

func flashlightFunc():
	if Input.is_action_just_pressed("Flashlight"):
		flashlight_click.play()
		flashlight.visible = not flashlight.visible

func Animations():
	if isMoving:
		
