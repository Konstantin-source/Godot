extends Node

signal shoot()
signal input_rotation_changed(new_input_rotation)
var target_angle: float           = 0.0
var time_since_last_change: float = 0.0
var player: CharacterBody2D       = null
var idle_rotation_time: float     = 3.0

@export var shoot_speed: float = 3.0
@export var detection_radius: int = 200
@export var chase_Plaser_radius: int = 300


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	time_since_last_change +=delta
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

	#Mein genereller Vorschlag: Ein Signal, ob ein Enemy, oder en spieler noch lebt. Darauf kann dann immer geprüft werden und ohne Probleme "losgelassen" werden


	if is_instance_valid(player) and is_instance_valid($".."):
		var distance_to_player = (player.global_position - $"..".global_position).length()

		if player and detection_radius >= distance_to_player:
			target_angle = (player.global_position - $"..".global_position).angle() +PI/2
			$"../tower".rotation = lerp_angle($"../tower".rotation, target_angle, delta * 5)
			shoot.emit()

		else:
			time_since_last_change +=delta
			if time_since_last_change >= idle_rotation_time:
				time_since_last_change = 0.0
				target_angle = $"../tower".rotation + randf_range(PI, -PI)

		$"../tower".rotation = lerp_angle($"../tower".rotation, target_angle, delta)
