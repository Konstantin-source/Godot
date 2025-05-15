extends Node

@onready var coin_counter: Node = get_node("/root/CoinCounter")
var victory_screen_scene = preload("res://Scenes/ui/victory_screen.tscn")

func _on_level_completed() -> void:
	show_victory_screen()

func show_victory_screen() -> void:
	var victory_screen = victory_screen_scene.instantiate()
	get_tree().root.add_child(victory_screen)
	victory_screen.show_victory()
	victory_screen.next_level_requested.connect(_on_next_level_requested)

func show_defeat_screen() -> void:
	var victory_screen = victory_screen_scene.instantiate()
	get_tree().root.add_child(victory_screen)
	victory_screen.show_defeat()

func _on_next_level_requested() -> void:
	# Here you would implement logic to load the next level
	var loading_screen = preload("res://Scenes/menu/loading_screen.tscn").instantiate()
	loading_screen.set_target_scene("res://Scenes/game.tscn") # Replace with next level path
	get_tree().get_root().add_child(loading_screen)
	# No need to free the current level as the victory screen handles its own cleanup