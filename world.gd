extends Node3D
@onready var player_spawn = $PlayerSpawn
@onready var camera_3d = $Camera3D
@onready var zombie = preload("res://Zombie.tscn")
@onready var spawn_1 = $"ZombieSpawns/Spawn 1"
@export var EnemiesToggle:bool = false
var newZombie

# Called when the node enters the scene tree for the first time.
func _ready():
	camera_3d.queue_free()
	if EnemiesToggle:
		newZombie = zombie.instantiate()
		add_child(newZombie)
		newZombie.global_position = spawn_1.global_position
	add_child(Global.Player)
	Global.Player.global_position = player_spawn.global_position
#	Global.Player.global_transform.origin = player_spawn.global_transform.origin


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	get_tree().call_group("Enemies", "update_target_position", Global.Player.global_transform.origin)
