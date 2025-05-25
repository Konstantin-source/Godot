extends Control

func _ready() -> void: 
	MusicManager.play_music(MusicManager.Music.LOBBY_MUSIC, -20)
	
func _on_play_pressed() -> void:
	SoundManager.play_soundeffect(SoundManager.Sound.UI_CLICK, 0)
	var loading_screen = preload("res://Scenes/menu/loading_screen.tscn").instantiate()
	loading_screen.set_target_scene("res://Scenes/game.tscn")
	get_tree().get_root().add_child(loading_screen)
	self.queue_free()
	
func _on_options_pressed() -> void:
	SoundManager.play_soundeffect(SoundManager.Sound.UI_CLICK, 0)
	get_tree().change_scene_to_file("res://Scenes/menu/options.tscn")

func _on_exit_pressed() -> void:
	SoundManager.play_soundeffect(SoundManager.Sound.UI_CLICK, 0)
	get_tree().quit()
