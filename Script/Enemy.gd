extends CharacterBody3D
var speed: float = 5

@onready var detection_area = $DetectionArea
@onready var navagent  = $NavigationAgent3D
@onready var hitbox = $HitBox
@onready var zombie = $"."
@onready var eyes = $Hitbox/BeanMesh/Marker3D/Eyes
@onready var animation_player = $AnimationPlayer

var Playerchase: bool = true

var maxhealth = 13
var health = maxhealth
var dead: bool = false

func _physics_process(delta):
	velocity = Vector3.ZERO
	if not dead:
		if Playerchase:
			eyes.look_at(Global.Player.global_transform.origin)
			eyes.rotation.x = clamp(eyes.rotation.x, deg_to_rad(0), deg_to_rad(90))
			navagent.set_target_position(Global.Player.global_transform.origin)
			var next_nav_point = navagent.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * speed
	move_and_slide()
	
#	if hitbox.overlaps_area(Player.hip_fire_laser):
#		print(hitbox.get_overlapping_bodies())
#		print("eat cheese")
	if health <= 0:
		dead = true
		animation_player.play("Death")

func detection_area_body_entered(body):
	if body.has_method("ThePlayer"):
		Playerchase = true


func detection_area_body_exited(body):
	if body.has_method("ThePlayer"):
		Playerchase = true

func TakeDamage(amount):
	print("ouch: ", amount)
	health -= amount

