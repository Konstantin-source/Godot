extends Node
@export var SPEED = 100.0
@export var detection_radius = 200
@export var chase_Plaser_radius = 300
@export var shoot_speed = 3.0
@export var damage_tank = 10

signal inputDirectionChanged(newInputDirection)
signal input_rotation_changed(new_input_rotation)
var time_since_last_change = 0.0
var time_since_last_shoot = 0.0
var idle_rotation_time = 3.0
var target_angle = 0.0
var current_health = 100
var can_take_damage = true
var can_shoot = true
var velocity: Vector2 = Vector2.ZERO
var direction : Vector2 = Vector2.ZERO
@export var bulletScene: PackedScene

signal shoot()
var player: CharacterBody2D       = null

var input_rotation : Vector2 = Vector2.UP

@onready var nav_Agent := $"../NavigationAgent2D" as NavigationAgent2D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	$"../Node2D/healthbar".init_health(current_health)
	
func _physics_process(delta: float) -> void:
	time_since_last_change +=delta
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

	#Mein genereller Vorschlag: Ein Signal, ob ein Enemy, oder en spieler noch lebt. Darauf kann dann immer geprüft werden und ohne Probleme "losgelassen" werden
	
	if is_instance_valid(player) and is_instance_valid($".."):
		nav_Agent.target_position = player.global_position
		var distance_to_player = (player.global_position - $"..".global_position).length()
		
		direction = (nav_Agent.get_next_path_position() - $"..".global_position).normalized()
		if distance_to_player <= chase_Plaser_radius and distance_to_player >= 300:
			inputDirectionChanged.emit(direction*-1)
		else:
			inputDirectionChanged.emit(Vector2.ZERO)
		
		time_since_last_shoot+=delta
		
		if player and detection_radius >= distance_to_player:
			var current = $"../tower".rotation
			var target  = (player.global_position - $"..".global_position).angle() + PI/2
			var smoothed = lerp_angle(current, target, delta * 3)
			var delta_angle = smoothed - current
			input_rotation = Vector2.UP.rotated(smoothed - PI/2)
			input_rotation_changed.emit(input_rotation)
			shoot.emit()
		else:
			time_since_last_change +=delta
			if time_since_last_change >= idle_rotation_time:
				time_since_last_change = 0.0
				target_angle =$"../tower".rotation + randf_range(PI, -PI)
				var rotate_angle: float = lerp_angle(input_rotation.angle(), target_angle, delta * 3)
				input_rotation_changed.emit(input_rotation.rotated(rotate_angle))
				
		$"../tower".rotation = lerp_angle($"../tower".rotation, target_angle, delta)
			

func make_Path() -> void:
	nav_Agent.target_position = player.global_position
	nav_Agent.path_changed


func _on_death_animation_finished() -> void:
	queue_free()


func _on_pathfinding_timer_timeout() -> void:
	if is_instance_valid(player):
		make_Path()
