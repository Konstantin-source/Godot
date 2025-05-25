extends Node

@export var audio_player_path: NodePath
@onready var player: AudioStreamPlayer2D = get_node(audio_player_path)
## -30 = no sound
@export var min_volume_db: float = -30.0
## 0 = full sound 
@export var max_volume_db: float = 0.0

var current_volume_db: float = min_volume_db

func update_volume(factor: float, delta: float):
	var target_volume_db = lerp(min_volume_db, max_volume_db, factor) # ziel lautstärke berechnen
	current_volume_db = lerp(current_volume_db, target_volume_db, 2 * delta) # an ziel angleichen
	player.volume_db = current_volume_db
	_play_if_needed()

func _play_if_needed():
	if !player.playing:
		player.play()
		
func stop():
	if player.playing:
		player.stop()
