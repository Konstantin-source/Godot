extends Node

signal all_enemies_defeated

var total_enemies = 0
var defeated_enemies = 0
var enemies_remaining = 0

@onready var coin_counter = get_node("/root/CoinCounter")
@onready var level_manager = get_node("/root/LevelManager")

func _ready() -> void:
	# Register for level loading complete notification from the LevelManager autoload
	var level_manager = get_node_or_null("/root/LevelManager")
	if level_manager and level_manager.has_signal("level_loaded"):
		level_manager.level_loaded.connect(_on_level_loaded)
		print("Connected to LevelManager level_loaded signal")
	else:
		push_warning("LevelManager not found or doesn't have level_loaded signal, using fallback")
		# Fallback: initialize after a short delay
		await get_tree().create_timer(0.2).timeout
		initialize_enemies()

func _on_level_loaded() -> void:
	print("Level loaded signal received from LevelManager, initializing enemies...")
	initialize_enemies()

func initialize_enemies() -> void:
	# Reset counters
	reset_enemy_counters()
	
	# Count enemies and connect signals
	var enemy_nodes = get_tree().get_nodes_in_group("enemy")
	for enemy in enemy_nodes:
		if enemy.is_in_group("enemy"):
			total_enemies += 1
			enemies_remaining += 1

			var enemy_controller = enemy.get_node_or_null("EnemyController")
			if enemy_controller and enemy_controller.has_signal("tank_destroyed"):
				enemy_controller.tank_destroyed.connect(_on_enemy_destroyed)
				print("Connected tank_destroyed signal to: ", enemy.name)
			else:
				print("EnemyController not found or does not have tank_destroyed signal: ", enemy.name)
	
	print("Total enemies initialized: ", total_enemies)

func reset_enemy_counters() -> void:
	total_enemies = 0
	defeated_enemies = 0
	enemies_remaining = 0

func _on_enemy_destroyed() -> void:
	defeated_enemies += 1
	enemies_remaining -= 1

	for i in range(1, 10):
		coin_counter._add_coin()
	
	print("Enemy destroyed! Remaining: ", enemies_remaining, "/", total_enemies)
	
	_check_victory_condition()

func _check_victory_condition() -> void:
	if enemies_remaining <= 0:
		print("All enemies defeated.")
		
		await get_tree().create_timer(1.5).timeout
		all_enemies_defeated.emit()
		
		if level_manager and level_manager.has_method("show_victory_screen"):
			level_manager.show_victory_screen()

func get_enemies_remaining() -> int:
	return enemies_remaining
