extends Node

# Signals
signal all_enemies_defeated

# Variables
var total_enemies = 0
var defeated_enemies = 0
var enemy_spawners = []
var enemies_remaining = 0
var all_enemies_spawned = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Find all enemy spawners in the scene
	call_deferred("find_enemy_spawners")
	
# Searches for enemy spawners in the scene
func find_enemy_spawners() -> void:
	await get_tree().process_frame
	
	# Find all enemy spawner nodes
	var spawners = get_tree().get_nodes_in_group("enemy_spawner")
	if spawners.size() > 0:
		enemy_spawners = spawners
		
		# Calculate total enemies from all spawners
		for spawner in spawners:
			if spawner.has_method("get_enemy_count"):
				total_enemies += spawner.get_enemy_count()
			elif "howManyEnemys" in spawner:
				total_enemies += spawner.howManyEnemys
				
		enemies_remaining = total_enemies
		print("EnemyManager: Found ", total_enemies, " total enemies to spawn")
	else:
		# If no spawners found, count existing enemies
		var enemies = get_tree().get_nodes_in_group("enemy")
		total_enemies = enemies.size()
		enemies_remaining = total_enemies
		all_enemies_spawned = true
		
		# Connect to their destroyed signal
		for enemy in enemies:
			if enemy.has_node("EnemyController"):
				enemy.get_node("EnemyController").tank_destroyed.connect(_on_enemy_destroyed)
				
		print("EnemyManager: Found ", total_enemies, " existing enemies")
	
	# If no enemies in level, trigger victory immediately
	if total_enemies == 0:
		call_deferred("_check_victory_condition")

# Called when an enemy is spawned
func register_enemy(enemy) -> void:
	if "EnemyController" in enemy:
		enemy.EnemyController.tank_destroyed.connect(_on_enemy_destroyed)
	elif enemy.has_node("EnemyController"):
		enemy.get_node("EnemyController").tank_destroyed.connect(_on_enemy_destroyed)
	
	enemies_remaining += 1

# Called when an enemy spawner is finished
func _on_spawner_finished() -> void:
	var all_finished = true
	
	for spawner in enemy_spawners:
		if spawner.has_method("is_spawning_complete") and !spawner.is_spawning_complete():
			all_finished = false
			break
	
	if all_finished:
		all_enemies_spawned = true
		print("EnemyManager: All enemies have been spawned")

# Called when an enemy is destroyed
func _on_enemy_destroyed() -> void:
	defeated_enemies += 1
	enemies_remaining -= 1
	
	print("Enemy destroyed! Remaining: ", enemies_remaining, "/", total_enemies)
	
	# Check if all enemies are defeated
	_check_victory_condition()

# Checks if victory conditions are met
func _check_victory_condition() -> void:
	if enemies_remaining <= 0 and (all_enemies_spawned or defeated_enemies >= total_enemies):
		print("All enemies defeated! Victory!")
		
		# Wait a moment before declaring victory
		await get_tree().create_timer(1.5).timeout
		all_enemies_defeated.emit()
		
		# Find level manager and show victory screen
		var level_manager = get_tree().get_root().get_node_or_null("Game/LevelManager")
		if level_manager and level_manager.has_method("show_victory_screen"):
			level_manager.show_victory_screen()

# Returns how many enemies are left
func get_enemies_remaining() -> int:
	return enemies_remaining
