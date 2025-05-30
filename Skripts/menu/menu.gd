extends Control

func _on_play_pressed() -> void:
	LoadingScreen.start_loading("res://Scenes/Level/lvl_1.tscn", true)
	self.queue_free()

func _on_level_select_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu/level_select.tscn")

func _on_shop_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu/shop.tscn")
	
func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu/options.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
