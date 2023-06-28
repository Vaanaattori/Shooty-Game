extends StaticBody3D
@onready var mesh_instance_3d = $MeshInstance3D
@onready var collision_shape_3d = $CollisionShape3D


# Called when the node enters the scene tree for the first time.
func _ready():
	collision_shape_3d.scale = mesh_instance_3d.scale * 2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
