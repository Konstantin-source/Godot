extends Control

func _on_play_pressed() -> void:
	var loading_screen = preload("res://Scenes/menu/loading_screen.tscn").instantiate()
	get_tree().get_root().add_child(loading_screen)
	loading_screen._start_loading("res://Scenes/Level/lvl_1.tscn", true)
	self.queue_free()
	
func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu/options.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
