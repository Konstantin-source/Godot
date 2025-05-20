extends Node

@onready var coin_counter: Node = get_node("/root/CoinCounter")
var victory_screen_scene = preload("res://Scenes/ui/victory_screen.tscn")
var game_over = false

func _on_level_completed() -> void:
	show_victory_screen()

func show_victory_screen() -> void:
	if game_over:
		return
	game_over = true
	
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

func _on_next_level_requested() -> void:
	var loading_screen = preload("res://Scenes/menu/loading_screen.tscn").instantiate()
	loading_screen.set_target_scene("res://Scenes/game.tscn")
	get_tree().get_root().add_child(loading_screen)