extends Node

signal level_loaded

var levels: Array[LevelData] = [
	LevelData.new("Level 1", preload("res://Scenes/Level/lvl_1.tscn"), 10),
	LevelData.new("Level 2", preload("res://Scenes/Level/lvl_2.tscn"), 20),
]
var current_level_index: int = 0
var unlocked_levels: Array[LevelData] = []
var current_level: Node = null

var victory_screen_scene = preload("res://Scenes/ui/victory_screen.tscn")
var game_over = false

func _ready():
	SaveManager.register_for_data(self, "_on_save_data_loaded")
	# Connect to notifications to detect when a level is loaded
	get_tree().node_added.connect(_on_node_added)

func _on_node_added(node: Node) -> void:
	# Check if a level scene was added
	if node.name.begins_with("Lvl_"):
		# Wait a little bit to ensure level is fully initialized
		await get_tree().create_timer(0.2).timeout
		print("Level scene detected: " + node.name)
		current_level = node
		notify_level_loaded()

func notify_level_loaded() -> void:
	print("Notifying that level has loaded")
	game_over = false
	level_loaded.emit()

func _on_level_completed() -> void:
	show_victory_screen()

func show_victory_screen() -> void:
	if game_over:
		return
	game_over = true

	SaveManager._save_completed_level(current_level_index + 1)
	
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 10
	get_tree().root.add_child(canvas_layer)
	
	var victory_screen = victory_screen_scene.instantiate()
	canvas_layer.add_child(victory_screen)
	victory_screen.show_victory()
	victory_screen.next_level_requested.connect(_on_next_level_requested)

func show_defeat_screen() -> void:
	if game_over:
		return
	game_over = true

	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 10
	get_tree().root.add_child(canvas_layer)
	
	var victory_screen = victory_screen_scene.instantiate()
	canvas_layer.add_child(victory_screen)
	victory_screen.show_defeat()
	victory_screen.retry_level_requested.connect(_on_retry_level_requested)

func _on_next_level_requested() -> void:
	if current_level:
		current_level.queue_free()
		current_level = null

	current_level_index += 1

	var loading_screen = preload("res://Scenes/menu/loading_screen.tscn").instantiate()
	get_tree().get_root().add_child(loading_screen)
	loading_screen._start_loading(levels[current_level_index].level_scene.resource_path, true)

func _on_retry_level_requested() -> void:
	if current_level:
		current_level.queue_free()
		current_level = null

	var loading_screen = preload("res://Scenes/menu/loading_screen.tscn").instantiate()
	get_tree().get_root().add_child(loading_screen)
	loading_screen._start_loading(levels[current_level_index].level_scene.resource_path, true)

func _on_level_requested(level_number: int) -> void:
	if level_number < levels.size():
		current_level_index = level_number
		var loading_screen = preload("res://Scenes/menu/loading_screen.tscn").instantiate()
		get_tree().get_root().add_child(loading_screen)
		loading_screen._start_loading(levels[current_level_index].level_scene.resource_path, true)
	else:
		print("Level not found")

func _on_save_data_loaded(save_data: Dictionary) -> void:
	if save_data["completed_levels"].size() > 0:
		for level_number in save_data["completed_levels"]:
			unlocked_levels.append(levels[level_number - 1])

func get_current_level_max_coins() -> int:
	if current_level_index < levels.size():
		return levels[current_level_index].max_coins
	return 0
