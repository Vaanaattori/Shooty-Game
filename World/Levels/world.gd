extends Node3D
@onready var player_spawn = $PlayerSpawn
@onready var camera_3d = $Camera3D
@onready var spawn_1 = $"ZombieSpawns/Spawn 1"
@onready var zombiespawns = $ZombieSpawns
@onready var spawnTimer = $SpawnTimer
var enemySpawnPoints := []
@export_category("Enemies")
@export var zombie:PackedScene
@export var EnemiesToggle:bool = false
@export_category("RoundSettings")
@export var spawnSpeed := 1.0
@export var spawnAmount := 10
@export var spawnedEnemies := 0
@export var CurrentWave: int = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	camera_3d.queue_free()
	add_child(Global.Player)
	spawnTimer.wait_time = spawnSpeed
	Global.Player.global_position = player_spawn.global_position
	if EnemiesToggle:
		startWave()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	get_tree().call_group("Enemies", "update_target_position", Global.Player.global_transform.origin)
func startWave():
	enemySpawnPoints.clear()
	for spawnpoint in zombiespawns.get_children():
		if spawnpoint is Marker3D and spawnpoint.Spawnable:
			enemySpawnPoints.append(spawnpoint)
	spawnedEnemies = 0
	CurrentWave += 1
	spawnTimer.start()

func spawnEnemy():
	if spawnedEnemies < spawnAmount:
		if enemySpawnPoints.size() > 0:
			var PossibleSpawns = []
			for spawnpoint in enemySpawnPoints:
				if spawnpoint.is_in_group("Spawnable"):
					PossibleSpawns.append(spawnpoint)
			var spawnArea
			if not PossibleSpawns.is_empty():
				spawnArea = PossibleSpawns[randi() % PossibleSpawns.size()]
			if spawnArea != null:
				var enemy = zombie.instantiate()
				enemy.position = spawnArea.global_position# + Vector2(randf_range(-spawnArea.spawnRadius.x, spawnArea.spawnRadius.x), randf_range(-spawnArea.spawnRadius.z, spawnArea.spawnRadius.z))
				add_child(enemy)
				spawnedEnemies += 1
			else:
				print("All Spawns Are Occupied")
			if spawnedEnemies == spawnAmount:
				spawnTimer.stop()
		else:
			print("No spawnable areas found!")
	else:
		spawnTimer.stop()


