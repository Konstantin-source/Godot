extends Node2D

@export var bullet_scene: PackedScene = preload("res://Scenes/bullet/bullet.tscn")  # Projektilszene
@export var range: float = 500.0       # Erkennungs- und Schussreichweite
@export var shoot_speed: float = 0.5  # Zeit zwischen den Schüssen
@export var damage_tank: int = 10

signal shoot()
var time_since_last_change: float = 0.0
var idle_rotation_time: float = 3.0
var target_angle: float = 0.0
var can_take_damage: bool = true
var can_shoot: bool = true

var player: CharacterBody2D = null

func _ready() -> void:
	# Hole den Spieler (stelle sicher, dass der Pfad korrekt ist)
	player = get_parent().get_node("Player")
	
func _physics_process(delta: float) -> void:
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
	$death.show()
	$death.play("death")
	$tower.hide()
	$base.hide()
		
func _on_death_animation_finished() -> void:
	queue_free()
