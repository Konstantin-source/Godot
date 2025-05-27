extends Node

# --- Export-Variablen ---
@export var chase_player_radius: int = 300
@export var bulletScene: PackedScene

@export var death_animation: AnimatedSprite2D
@export var nodes_to_remove: Array[Node2D] = []
@export var nodes_to_disable: Array[CollisionShape2D] = []
##Bestimmt die Maximale Entfernung, vom ziel (Spieler) und dem eigentlichen Ziel, dass dem Path gesetzt wurde, um kollisionen zu vermeiden
@export var random_offset_pixel : int = 200
var random_offset : Vector2 = Vector2.ZERO

# --- Signale ---
signal shoot()

# --- Interne Zustandsvariablen ---
var time_since_last_change: float = 0.0
var time_since_last_shoot: float = 0.0
var current_health: int = 100
var can_take_damage: bool = true
var can_shoot: bool = true
var velocity: Vector2 = Vector2.ZERO
var direction: Vector2 = Vector2.ZERO
var player: CharacterBody2D = null
var avoidance_correction : Vector2 = Vector2.ZERO
var freeze_avoidance_correction :bool = false
var idle_movement_position : Vector2 = Vector2.ZERO
var idle_movement :bool = true
var movement_pattern :int = 0
@export var circle_angular_speed: float = 1.0
@export var desired_distance: float = 200.0

#Enums
enum states { IDLE, FOLLOWING, CIRCLE, DISTANCE }


func _ready() -> void:
	randomize()
	$"../enemyHealth/healthbar".init_health(current_health)
	

func _physics_process(delta: float) -> void:
	pass


	
func _on_tank_destroyed() -> void:
	player = null
	can_shoot = false

	death_animation.show()
	death_animation.play("death")
	for node in nodes_to_remove:
		node.queue_free()
	for node in nodes_to_disable:
		node.disabled = true

func _on_death_animation_finished() -> void:
	$"..".queue_free()



		



	
	
	
