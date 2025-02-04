extends CharacterBody2D
@export var SPEED = 300.0
@export var detection_radius = 200
var time_since_last_change = 0.0
var idle_rotation_time = 3.0
var target_angle = 0.0


var player: CharacterBody2D = null


func _ready() -> void:
	player = get_parent().get_node("Player")
	
	
func _physics_process(delta: float) -> void:
	var distance_to_player = (player.global_position - global_position).length()
	if player and detection_radius >= distance_to_player:
		target_angle = (player.global_position - global_position).angle() +PI/2
		$tower.rotation = lerp_angle($tower.rotation, target_angle, delta * 5)
		
	else:
		time_since_last_change +=delta
		if time_since_last_change >= idle_rotation_time:
			time_since_last_change = 0.0
			target_angle = $tower.rotation + randf_range(PI, -PI)
			
	$tower.rotation = lerp_angle($tower.rotation, target_angle, delta)
			
	
	
	
func shoot():
	pass



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("get_global_position"):
		var body_position = body.global_position
		$tower.rotation = (global_position - body_position).angle()
