extends Node3D
@onready var player_spawn = $PlayerSpawn
@onready var camera_3d = $Camera3D


# Called when the node enters the scene tree for the first time.
func _ready():
	camera_3d.queue_free()
	add_child(Global.Player)
	Global.Player.global_transform.origin = player_spawn.global_transform.origin


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	get_tree().call_group("Enemies", "update_target_position", Global.Player.global_transform.origin)
