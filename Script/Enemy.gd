extends CharacterBody3D
var speed: float = 1000000000
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var detection_area = $DetectionArea
@onready var navagent  = $NavigationAgent3D

func _physics_process(delta):
	var current_location = global_transform.origin
	var next_location = navagent.get_next_path_position()
	var velocity = (next_location - current_location).normalized() * speed
	print(velocity)
#	velocity = new_velocity
	move_and_slide()
	update_target_location(Player.global_transform.origin)
#	if detection_area.overlaps_body(Player):
#		look_at(Player.global_position)

func update_target_location(x):
	navagent.set_target_position(x)
	
		
