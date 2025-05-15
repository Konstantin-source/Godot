extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 2.0
@export var howManyEnemys: int = 10

var current_time :float = 0.0
var spawned_count = 0
var enemy_manager = null
signal spawning_complete

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Add to enemy_spawner group so EnemyManager can find it
	add_to_group("enemy_spawner")
	
	# Find the enemy manager
	call_deferred("find_enemy_manager")

func find_enemy_manager() -> void:
	await get_tree().process_frame
	enemy_manager = get_tree().get_root().get_node_or_null("Game/EnemyManager")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	current_time += delta
	if current_time >= spawn_interval and spawned_count < howManyEnemys:
		spawn_enemy()
		spawned_count += 1
		current_time = 0.0
		
		# Check if we've spawned all enemies
		if spawned_count >= howManyEnemys:
			spawning_complete.emit()
			if enemy_manager != null:
				enemy_manager._on_spawner_finished()
		
func spawn_enemy():
	if enemy_scene:
		var enemy = enemy_scene.instantiate()
		# Add to enemy group
		enemy.add_to_group("enemy")
		
		var temp_path_follow = $Path2D/PathFollow2D
		temp_path_follow.progress_ratio = randf()
		enemy.global_position = temp_path_follow.global_position
		get_tree().current_scene.add_child(enemy)
		
		# Register enemy with manager
		if enemy_manager != null:
			enemy_manager.register_enemy(enemy)

# Returns number of enemies from this spawner
func get_enemy_count() -> int:
	return howManyEnemys

# Returns true if spawner has finished spawning all enemies
func is_spawning_complete() -> bool:
	return spawned_count >= howManyEnemys
