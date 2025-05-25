extends Node

enum Music {
	INGAME_MUSIC,
	LOBBY_MUSIC,
	WIN
}

var music_map = {
Music.INGAME_MUSIC: preload("res://Sounds/Music/war-battle-military-drums-318680.mp3"),
Music.LOBBY_MUSIC: preload("res://Sounds/Music/army-music-military-war-battlefield-background-intro-theme-314656.mp3"),
Music.WIN :preload("res://Sounds/Music/vicory-music.mp3")
}
var music_player: AudioStreamPlayer

func _ready():
	music_player = AudioStreamPlayer.new()
	add_child(music_player)

func play_music (music: int, volume_db: float):
	if music_player.stream == music_map.get(music) and  music_player.playing:  # prüfen ob music schon läuft
		return
	# enum sound, lautstärke, postion zu player hinzufügen
	music_player.stream = music_map.get(music)
	music_player.volume_db = volume_db
	music_player.stream.loop = true # damit sich die musik wiederholt
	
	add_child(music_player)
	music_player.play()

func stop_music():
	if music_player and music_player.playing:
		music_player.stop()
	
