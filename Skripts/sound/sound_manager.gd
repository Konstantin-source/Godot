extends Node

enum Sound {
	SHOOT_NORMAL_BULLET,
	RELOAD_SOUND_TANK,
	UI_CLICK,
	DASH,
	EXPLOSION_TANK,
	COLLECT_COIN,
	ACTIVATE_SHIELD,
	WIN,
	LOOSE,
	TURRET_ROTATE,
	HITMARKER,
	SHOOT_BIG_BULLET,
	GET_HITTED_MARKER
}

var sound_map = {
Sound.RELOAD_SOUND_TANK: preload("res://Sounds/SFX/ShootingSounds/tank_reload.wav"),
Sound.SHOOT_NORMAL_BULLET: preload("res://Sounds/SFX/ShootingSounds/tank_shot.wav"),
Sound.UI_CLICK: preload("res://Sounds/SFX/UI/ui_click.wav"),
Sound.DASH: preload("res://Sounds/SFX/Movement/off-road-4cyl-hybrid-turbo-249824.wav"),
Sound.EXPLOSION_TANK: preload("res://Sounds/SFX/ShootingSounds/explosion.wav"),
Sound.COLLECT_COIN: preload("res://Sounds/SFX/More/collect_coin.wav"),
Sound.ACTIVATE_SHIELD: preload("res://Sounds/SFX/More/aktivate_shield.ogg"),
Sound.WIN: preload("res://Sounds/SFX/More/badass-victory.wav"),
Sound.LOOSE: preload("res://Sounds/SFX/More/failure.wav"),
Sound.TURRET_ROTATE: preload("res://Sounds/SFX/More/tank-turret-rotate-14879.wav"),
Sound.HITMARKER: preload("res://Sounds/SFX/ShootingSounds/hitmarker-sound-effect.wav"),
Sound.GET_HITTED_MARKER: preload("res://Sounds/SFX/ShootingSounds/hollow-tank-hit-47673.wav"),
Sound.SHOOT_BIG_BULLET: preload("res://Sounds/SFX/ShootingSounds/tank-shots-big.wav"),



}

func play_soundeffect (sound: int, volume_db: float):
	var sound_effect_player = AudioStreamPlayer.new() # kein 2d damit sound bei player bleibt
	# enum sound, lautstärke, postion zu player hinzufügen
	sound_effect_player.stream = sound_map.get(sound)
	sound_effect_player.volume_db = volume_db
	#sound_effect_player.position = position
	add_child(sound_effect_player)
	sound_effect_player.play()
	
	# entfernen wenn fertig
	sound_effect_player.connect("finished", Callable(sound_effect_player, "queue_free"))
		
