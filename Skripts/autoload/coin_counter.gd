extends Node

var total_coins: int = 0
var current_level_coins: int = 0

signal coin_count_changed(new_count: int)
signal level_coins_changed(level_coins: int)

@onready var save_manager: Node = get_node("/root/SaveManager")

func _ready() -> void:
	coin_count_changed.connect(save_manager._on_coin_count_changed)
	
	total_coins = save_manager.save_data["coin_count"]

func _add_coin() -> void:
	current_level_coins += 1
	level_coins_changed.emit(current_level_coins)
	
func complete_level() -> void:
	total_coins += current_level_coins
	coin_count_changed.emit(total_coins)
	
	current_level_coins = 0
	level_coins_changed.emit(current_level_coins)
	
func get_total_coins() -> int:
	return total_coins
	
func get_level_coins() -> int:
	return current_level_coins
