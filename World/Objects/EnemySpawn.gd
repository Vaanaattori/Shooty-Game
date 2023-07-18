extends Marker3D
@export var Spawnable:bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	if Spawnable:
		add_to_group("Spawnable")
	else:
		remove_from_group("Spawnable")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#When zombie is in front of spawn
func _on_area_3d_body_entered(body):
	if body.has_method("Enemy"):
		remove_from_group("Spawnable")

#When no mob is in front of spawn
func _on_area_3d_body_exited(body):
	if body.has_method("Enemy") and Spawnable:
		add_to_group("Spawnable")
