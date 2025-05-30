extends Node

var total_coins: int = 0
var current_level_coins: int = 0

signal coin_count_changed(new_count: int)
signal level_coins_changed(level_coins: int)

func _ready() -> void:
	coin_count_changed.connect(SaveManager._save_new_coin_count)
	
	SaveManager.register_for_data(self, "_on_save_data_loaded")

func _add_coin(amount: int = 1) -> void:
	current_level_coins += amount
	level_coins_changed.emit(current_level_coins)

func _remove_total_coins(amount: int) -> void:
	total_coins -= amount
	coin_count_changed.emit(total_coins)
	
func complete_level() -> void:
	total_coins += current_level_coins
	coin_count_changed.emit(total_coins)
	
	current_level_coins = 0
	level_coins_changed.emit(current_level_coins)

func _on_save_data_loaded(save_data: Dictionary) -> void:
	total_coins = save_data["coin_count"]
	
func get_total_coins() -> int:
	return total_coins
	
func get_level_coins() -> int:
	return current_level_coins
