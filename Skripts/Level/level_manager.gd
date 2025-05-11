extends Node

@onready var coin_counter: Node = get_node("/root/CoinCounter")

func _on_level_completed() -> void:
	coin_counter.complete_level()
	
	print("Level completed! Coins added to total.")
	# Here you could add level transition code, like:
	# get_tree().change_scene_to_file("res://Scenes/menu/loading_screen.tscn")