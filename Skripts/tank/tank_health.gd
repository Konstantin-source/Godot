extends Node

@export var max_health: int = 100
var current_health: int = max_health
var can_take_damage = true

signal init_health(health: int)
signal health_changed(new_health: int)
signal tank_destroyed()

func _ready() -> void:
	init_health.emit(max_health)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if "damage" in body and can_take_damage:
		if self.is_in_group("player"): # wenn spieler getroffen wird anderer sound 
			SoundManager.play_soundeffect(SoundManager.Sound.GET_HITTED_MARKER, 0)
		else : 
			SoundManager.play_soundeffect(SoundManager.Sound.HITMARKER, 0)
			
		start_damage_cooldown()
		var damage = body.damage
		current_health -= damage
		if current_health <= 0:
			current_health = 0
			health_changed.emit(current_health)
			tank_destroyed.emit()
		else:
			health_changed.emit(current_health)


func start_damage_cooldown():
	can_take_damage = false
	await get_tree().create_timer(0.2).timeout
	can_take_damage = true
