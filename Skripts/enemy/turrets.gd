extends Node2D

@export var range: float = 500.0       # Erkennungs- und Schussreichweite

@export var death_animation: AnimatedSprite2D
@export var nodes_to_remove: Array[Node2D] = []
@export var nodes_to_disable: Array[CollisionShape2D] = []

signal shoot()
var time_since_last_change: float = 0.0
var idle_rotation_time: float = 3.0
var target_angle: float = 0.0
var is_destroyed: bool = false

var player: CharacterBody2D = null

signal turret_destroyed()

func _ready() -> void:
	# Hole den Spieler (stelle sicher, dass der Pfad korrekt ist)
	player = get_parent().get_node("Player")
	
func _physics_process(delta: float) -> void:
	if is_destroyed:
		return

	if is_instance_valid(player):
		var distance_to_player = (player.global_position - global_position).length()
		
		if distance_to_player <= range:
			# Spieler in Reichweite – Turret richtet sich auf den Spieler aus
			target_angle = (player.global_position - global_position).angle() + PI/2
			$tower.rotation = lerp_angle($tower.rotation, target_angle, delta * 5)
			await get_tree().create_timer(2).timeout  # Erst 0.5s warten
			shoot.emit()
		else:
			#Spieler außerhalb der Reichweite – zufällige Idle-Rotation
			time_since_last_change += delta
			if time_since_last_change >= idle_rotation_time:
				time_since_last_change = 0.0
				target_angle = $tower.rotation + randf_range(-PI, PI)
			$tower.rotation = lerp_angle($tower.rotation, target_angle, delta)



func _on_turret_destroyed() -> void:
	if is_destroyed:
		return
	is_destroyed = true

	turret_destroyed.emit()
	death_animation.show()
	death_animation.play("death")

	for node in nodes_to_remove:
		node.queue_free()
	for node in nodes_to_disable:
		node.disabled = true
		
func _on_death_animation_finished() -> void:
	queue_free()
