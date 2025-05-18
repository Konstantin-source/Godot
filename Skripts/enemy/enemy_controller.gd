extends Node

# --- Export-Variablen ---
@export var turret_rotation_speed: float = 5.0
@export var detection_radius: int = 200
@export var chase_player_radius: int = 300
@export var bulletScene: PackedScene

@export var death_animation: AnimatedSprite2D
@export var nodes_to_remove: Array[Node2D] = []
@export var nodes_to_disable: Array[CollisionShape2D] = []
##Bestimmt die Maximale Entfernung, vom ziel (Spieler) und dem eigentlichen Ziel, dass dem Path gesetzt wurde, um kollisionen zu vermeiden
@export var random_offset_pixel : int = 200
var random_offset : Vector2 = Vector2.ZERO

# --- Signale ---
signal inputDirectionChanged(new_input_direction)
signal input_rotation_changed(new_input_rotation)
signal shoot()

# --- Interne Zustandsvariablen ---
var time_since_last_change: float = 0.0
var time_since_last_shoot: float = 0.0
var idle_rotation_time: float = 3.0
var target_angle: float = 0.0
var current_health: int = 100
var can_take_damage: bool = true
var can_shoot: bool = true
var velocity: Vector2 = Vector2.ZERO
var direction: Vector2 = Vector2.ZERO
var player: CharacterBody2D = null
var input_rotation: Vector2 = Vector2.UP
var avoidance_correction : Vector2 = Vector2.ZERO
var freeze_avoidance_correction :bool = false

@onready var nav_Agent := $"../NavigationAgent2D" as NavigationAgent2D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	$"../Node2D/healthbar".init_health(current_health)
	nav_Agent.set_avoidance_layer_value(1, true)
	nav_Agent.set_avoidance_mask_value(1, true)

func _physics_process(delta: float) -> void:
	time_since_last_change += delta
	await get_tree().process_frame  # Stellt sicher, dass alle Pfade aktuell sind

	player = get_tree().get_first_node_in_group("player")
	if not is_instance_valid(player) or not is_instance_valid($"../tower"):
		return

	# Navigation aktualisieren
	nav_Agent.target_position = player.global_position + random_offset
	var distance_to_player = (player.global_position - $"..".global_position).length()
	NavigationServer2D.agent_set_position(nav_Agent.get_rid(), $"..".global_position)
	direction = (nav_Agent.get_next_path_position() - $"..".global_position).normalized()
	NavigationServer2D.agent_set_velocity(nav_Agent.get_rid(), direction)

	var new_direction = NavigationServer2D.agent_get_velocity(nav_Agent.get_rid())
	
	# Richtung nur setzen, wenn Spieler im richtigen Bereich ist
	if distance_to_player <= chase_player_radius and distance_to_player >= 300:
		inputDirectionChanged.emit((-new_direction+avoidance_correction).normalized())
	else:
		inputDirectionChanged.emit(Vector2.ZERO)

	time_since_last_shoot += delta

	# Wenn Spieler in Reichweite ist, Turm ausrichten und feuern
	if distance_to_player <= detection_radius:
		var current = $"../tower".rotation
		target_angle = (player.global_position - $"..".global_position).angle() + PI / 2
		var target = lerp_angle(current, target_angle, delta * turret_rotation_speed)
		input_rotation = Vector2.UP.rotated(target)
		input_rotation_changed.emit(input_rotation)
		shoot.emit()
	else:
		# Zufällige Idle-Rotation nach Leerlaufzeit
		if time_since_last_change >= idle_rotation_time:
			time_since_last_change = 0.0
			var current = $"../tower".rotation
			target_angle = current + randf_range(-PI, PI)
			var target = lerp_angle(current, target_angle, delta * turret_rotation_speed)
			input_rotation = Vector2.UP.rotated(target)
			input_rotation_changed.emit(input_rotation)

	# Rotation setzen
	$"../tower".rotation = lerp_angle($"../tower".rotation, target_angle, delta)


func make_Path() -> void:
	nav_Agent.target_position = player.global_position
	nav_Agent.path_changed

	
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


func _on_pathfinding_timer_timeout() -> void:
	if is_instance_valid(player):
		make_Path()
		
func calculate_avoidance(vektor: Vector2)->void:
	if vektor.length() > 0.0 and !freeze_avoidance_correction:
		freeze_avoidance_correction = true
		avoidance_correction = vektor
		print("Avoidance: ",avoidance_correction)
		await get_tree().create_timer(.2).timeout
		freeze_avoidance_correction = false
	elif vektor.length() == 0.0:
		avoidance_correction = avoidance_correction.lerp(Vector2.ZERO, get_process_delta_time() * 0.5)
	


func _on_random_position_timer_timeout() -> void:
	random_offset = Vector2(randi_range(-random_offset_pixel,random_offset_pixel), 
	randi_range(-random_offset_pixel,random_offset_pixel))
