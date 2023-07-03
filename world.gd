extends Node3D
@onready var player_spawn = $PlayerSpawn


# Called when the node enters the scene tree for the first time.
func _ready():
	Player.global_transform.origin = player_spawn.global_transform.origin


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	get_tree().call_group("Enemies", "update_target_position", Player.global_transform.origin)
