extends Control

func _on_play_pressed() -> void:
	var loading_screen = preload("res://Szenes/loading_screen.tscn").instantiate()
	loading_screen.set_target_scene("res://Szenes/game.tscn")
	get_tree().get_root().add_child(loading_screen)
	self.queue_free()
	
func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://Szenes/options.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
