extends CharacterBody3D
var speed: float = 1

@onready var detection_area = $DetectionArea
@onready var navagent  = $NavigationAgent3D

func _physics_process(delta):
	velocity = Vector3.ZERO
	if detection_area.overlaps_body(Player):
		look_at(Player.global_transform.origin)
		navagent.set_target_position(Player.global_transform.origin)
		var next_nav_point = navagent.get_next_path_position()
		velocity = (next_nav_point - global_transform.origin) * speed
	move_and_slide()
