extends Node
@export var turret_rotation_speed: float = 5.0
@export var detection_radius: int = 200
@export var chase_player_radius: int = 300
@export var bulletScene: PackedScene

@export var death_animation: AnimatedSprite2D
@export var nodes_to_remove: Array[Node2D] = []
@export var nodes_to_disable: Array[CollisionShape2D] = []
@export var scripts_to_disable: Array[Node] = []

signal inputDirectionChanged(newInputDirection)
signal input_rotation_changed(new_input_rotation)
signal shoot()
signal tank_destroyed()

var time_since_last_change: float = 0.0
var time_since_last_shoot: float  = 0.0
var idle_rotation_time: float     = 3.0
var target_angle: float           = 0.0
var current_health: int           = 100
var can_take_damage: bool         = true
var can_shoot: bool               = true
var velocity: Vector2             = Vector2.ZERO
var direction: Vector2            = Vector2.ZERO
var player: CharacterBody2D = null
var input_rotation: Vector2 = Vector2.UP
var is_destroyed: bool = false

@onready var nav_Agent := $"../NavigationAgent2D" as NavigationAgent2D


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	$"../Node2D/healthbar".init_health(current_health)
	

func _physics_process(delta: float) -> void:
	if is_destroyed:
		return
		
	time_since_last_change +=delta
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

	#Mein genereller Vorschlag: Ein Signal, ob ein Enemy, oder en spieler noch lebt. Darauf kann dann immer geprüft werden und ohne Probleme "losgelassen" werden

	if is_instance_valid(player) and is_instance_valid($"../tower"):
		nav_Agent.target_position = player.global_position
		var distance_to_player = (player.global_position - $"..".global_position).length()

		direction = (nav_Agent.get_next_path_position() - $"..".global_position).normalized()
		if distance_to_player <= chase_player_radius and distance_to_player >= 300:
			inputDirectionChanged.emit(direction*-1)
		else:
			inputDirectionChanged.emit(Vector2.ZERO)

		time_since_last_shoot+=delta

		if player and detection_radius >= distance_to_player:
			var current       = $"../tower".rotation
			target_angle = (player.global_position - $"..".global_position).angle() + PI / 2
			var target: float = lerp_angle(current, target_angle, delta * turret_rotation_speed)
			input_rotation = Vector2.UP.rotated(target)
			input_rotation_changed.emit(input_rotation)
			shoot.emit()
		else:
			time_since_last_change +=delta
			if time_since_last_change >= idle_rotation_time:
				time_since_last_change = 0.0
				var current       = $"../tower".rotation
				target_angle =$"../tower".rotation + randf_range(PI, -PI)
				var target: float = lerp_angle(current, target_angle, delta * turret_rotation_speed)
				input_rotation = Vector2.UP.rotated(target)
				input_rotation_changed.emit(input_rotation)

		$"../tower".rotation = lerp_angle($"../tower".rotation, target_angle, delta)


func make_Path() -> void:
	nav_Agent.target_position = player.global_position
	# TODO: what is this for?
	nav_Agent.path_changed

	
func _on_tank_destroyed() -> void:
	if is_destroyed:
		return
	is_destroyed = true

	player = null
	can_shoot = false

	death_animation.show()
	death_animation.play("death")
	for node in nodes_to_remove:
		node.queue_free()
	for node in nodes_to_disable:
		node.disabled = true
	for script in scripts_to_disable:
		script.set_process(false)

	$".".set_process(false)
		
	tank_destroyed.emit()

func _on_death_animation_finished() -> void:
	$"..".queue_free()


func _on_pathfinding_timer_timeout() -> void:
	if is_instance_valid(player):
		make_Path()
