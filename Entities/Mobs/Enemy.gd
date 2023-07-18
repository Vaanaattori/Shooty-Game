extends CharacterBody3D
var speed: float = 3

@onready var detection_area = $DetectionArea
@onready var navagent  = $NavigationAgent3D
@onready var hitbox = $HitBox
@onready var zombie = $"."
#@onready var eyes = $Hitbox/BeanMesh/Marker3D/Eyes
@onready var animation_player = $ColissionBox/Zombie/AnimationPlayer


@export var Damage:int
@export var Playerchase: bool = false
@export var maxhealth: int = 13
var health
var dead: bool = false
var PlayerInAttackRange
@export var Attacking: bool = false

func _ready():
	health = maxhealth

func _physics_process(delta):
	velocity = Vector3.ZERO
	
	if not dead:
		if PlayerInAttackRange:
			Attack()
			
		if Playerchase:
			if not PlayerInAttackRange:
				animation_player.play("Walk")
#			eyes.rotation.x = clamp(eyes.rotation.x, deg_to_rad(0), deg_to_rad(90))
			navagent.set_target_position(Global.Player.global_transform.origin)
			var next_nav_point = navagent.get_next_path_position()
			look_at(next_nav_point)
			rotation_degrees.x = 0
			rotation_degrees.z = 0
			velocity = (next_nav_point - global_transform.origin).normalized() * speed
		elif not PlayerInAttackRange:
			animation_player.play("Idle")
	move_and_slide()
	
#	if hitbox.overlaps_area(Player.hip_fire_laser):
#		print(hitbox.get_overlapping_bodies())
#		print("eat cheese")
	if health <= 0:
		dead = true
		PlayerStats.money += 100
		queue_free()
#		animation_player.play("Death")

func detection_area_body_entered(body):
	if body.has_method("ThePlayer"):
		Playerchase = true


func detection_area_body_exited(body):
	if body.has_method("ThePlayer"):
		Playerchase = false

func TakeDamage(amount):
	print("ouch: ", amount)
	health -= amount

func Attack():
	if Attacking:
		Global.Player.TakeDamage(Damage)

func _on_attack_range_body_entered(body):
	if body.has_method("ThePlayer"):
		print("attackrange")
		PlayerInAttackRange = true
		animation_player.play("Attack")

func _on_attack_range_body_exited(body):
	if body.has_method("ThePlayer"):
		PlayerInAttackRange = false

func Enemy():
	pass
