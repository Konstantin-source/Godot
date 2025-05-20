extends Node

@export var max_health: int = 100
var current_health: int = 0
var can_take_damage = true

signal init_health(health: int)
signal health_changed(new_health: int)
signal tank_destroyed()

func _ready() -> void:
	init_health.emit(max_health)
	current_health = max_health

func take_damage(damage: int) -> void:
	if can_take_damage:
		current_health -= damage
		if current_health <= 0:
			current_health = 0
			health_changed.emit(current_health)
			tank_destroyed.emit()
		else:
			health_changed.emit(current_health)
