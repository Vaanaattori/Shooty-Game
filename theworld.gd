extends Node2D

@export var mob_scene: PackedScene
@export var enemyCount = 1
@onready var player = $Player

var lastRandomSpawnMarkers = []
var markerCount = 5
var randomSpawnMarker
var mob

func _ready():
	rerollRandomSpawnMarker()
	spawnEnemies()

func _process(delta):
	pass

func rerollRandomSpawnMarker():
	randomSpawnMarker = randi() % markerCount + 1
	while lastRandomSpawnMarkers.has(randomSpawnMarker):
		randomSpawnMarker = randi() % markerCount + 1
	lastRandomSpawnMarkers.append(randomSpawnMarker)
	return randomSpawnMarker

func spawnEnemies():
	for marker in range(2):
		var SpawnMarker = "SpawnLocations/Spawn" + str(rerollRandomSpawnMarker())
		print(SpawnMarker)
		mob = mob_scene.instantiate()
		get_node(SpawnMarker).add_child(mob)
func _on_cliffisde_transition_point_body_entered(body):
	print(body)
	if body.has_method("player"):
		print("enter")
		get_tree().change_scene_to_file("res://Scenes/Areas/cave_entrance.tscn")


func _on_cliffisde_transition_point_body_exited(body):
	if body.has_method("player"):
		Global.transition_scene = false


func _on_player_attacking(damage):
	print("bonk")
	if mob.hitbox.has_overlapping_areas():
		print("bigbonks")
		mob.takeDamage(damage)
