extends Control

func _on_volume_pressed() -> void:
	print("Volume wurde gedürckt!")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu/menue.tscn")
