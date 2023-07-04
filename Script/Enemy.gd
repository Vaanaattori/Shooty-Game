extends CharacterBody3D
var speed: float = 1

@onready var detection_area = $DetectionArea
@onready var navagent  = $NavigationAgent3D
@onready var hitbox = $HitBox
@onready var zombie = $"."

var Playerchase: bool = false

func _physics_process(delta):
	velocity = Vector3.ZERO
	if Playerchase:
		look_at(Global.Player.global_transform.origin)
		navagent.set_target_position(Global.Player.global_transform.origin)
		var next_nav_point = navagent.get_next_path_position()
		velocity = (next_nav_point - global_transform.origin) * speed
	move_and_slide()
	
#	if hitbox.overlaps_area(Player.hip_fire_laser):
#		print(hitbox.get_overlapping_bodies())
#		print("eat cheese")


func detection_area_body_entered(body):
	if body.has_method("ThePlayer"):
		Playerchase = true


func detection_area_body_exited(body):
	if body.has_method("ThePlayer"):
		Playerchase = false
