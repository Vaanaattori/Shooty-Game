extends CharacterBody3D
var speed: float = 3

@onready var detection_area = $DetectionArea
@onready var navagent  = $NavigationAgent3D
@onready var hitbox = $HitBox
@onready var zombie = $"."
#@onready var eyes = $Hitbox/BeanMesh/Marker3D/Eyes
@onready var animation_player = $ColissionBox/Zombie/AnimationPlayer
@onready var attack_range = $ColissionBox/Zombie/AttackRange

@export_group("Stats")
@export var Damage:int
@export var maxhealth: int = 13
@export var PermaChase: bool = true
@export_group("Animation Stuff (IGNORE)")
@export var Attacking: bool = false
@export var HasAttacked: bool = false

var Playerchase: bool = true
var health
var Exit
var dead: bool = false
var PlayerInAttackRange
var Stunned: bool = false

func _ready():
	health = maxhealth

func _physics_process(delta):
	velocity = Vector3.ZERO
	
	if not dead:
		if not Global.Player.Dead:
			if not Stunned:
				if PlayerInAttackRange or PermaChase:
					print("not stunned")
	#				if PlayerInAttackRange:
	#					Attack()
					for Player in attack_range.get_overlapping_bodies():
						if Player.has_method("ThePlayer"):
							animation_player.play("Attack")
							PlayerInAttackRange = true
						else: PlayerInAttackRange = false
					if Attacking and not HasAttacked:
						Global.Player.TakeDamage(Damage)
						HasAttacked = true
					elif not Attacking:
						HasAttacked = false
					
					if Playerchase or PermaChase:
						if not PlayerInAttackRange:
							animation_player.play("Walk")
						navagent.set_target_position(Global.Player.global_transform.origin)
						var next_nav_point = navagent.get_next_path_position()
						look_at(next_nav_point)
						rotation_degrees.x = 0
						rotation_degrees.z = 0
						velocity = (next_nav_point - global_transform.origin).normalized() * speed
					elif not PlayerInAttackRange:
						animation_player.play("Idle")
		else:
			animation_player.play("Walk")
			var next_nav_point = navagent.get_next_path_position()
			navagent.set_target_position(Exit.global_transform.origin)
			look_at(next_nav_point)
			rotation_degrees.x = 0
			rotation_degrees.z = 0
			velocity = (next_nav_point - global_transform.origin).normalized() * speed
	move_and_slide()
	
#	if hitbox.overlaps_area(Player.hip_fire_laser):
#		print(hitbox.get_overlapping_bodies())
#		print("eat cheese")
	if health <= 0 and not dead:
		dead = true
		PlayerStats.money += 100
		animation_player.stop()
		animation_player.play("Death")

func detection_area_body_entered(body):
	if body.has_method("ThePlayer"):
		Playerchase = true

func detection_area_body_exited(body):
	if body.has_method("ThePlayer"):
		Playerchase = false

func TakeDamage(amount):
	print("ouch: ", amount)
	health -= amount

func Stun(Length):
	var StunTimer = $StunDur
	StunTimer.wait_time = Length
	Stunned = true
	StunTimer.start()
	animation_player.play("Stun")

func _on_attack_range_body_entered(body):
	if body.has_method("ThePlayer") and not Stunned:
		print("attackrange")
		PlayerInAttackRange = true
		

func _on_attack_range_body_exited(body):
	if body.has_method("ThePlayer"):
		PlayerInAttackRange = false

func Enemy():
	pass

func Stun_Timeout():
	Stunned = false
