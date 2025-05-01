extends Node

@export var max_health: int = 100
var current_health: int = max_health

signal init_health(health: int)
signal health_changed(new_health: int)
signal tank_destroyed()

func _ready() -> void:
	init_health.emit(max_health)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if "damage" in body:
		var damage = body.damage
		current_health -= damage
		if current_health <= 0:
			current_health = 0
			health_changed.emit(current_health)
			tank_destroyed.emit()
		else:
			health_changed.emit(current_health)
