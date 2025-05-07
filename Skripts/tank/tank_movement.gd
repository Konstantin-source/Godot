extends CharacterBody2D

@onready var rotation_degree = $body.rotation
@export var acceleration_duration: float = 0.5
@export var deceleration_duration: float = 1.5
@export var acc_curve : Curve
@export var acceleration_time: float = 0.0
@export var speed: int               = 200
var deceleration_time: float = 0.5
var speed_scale: int         = 0

signal spawn_new_track_mark()
var input_direction: Vector2    = Vector2.ZERO
var rotation_direction: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if (!is_instance_valid($body)):
		return
		
	rotation_degree = input_direction.angle() - PI/2
	if input_direction != Vector2.ZERO:
		#rotieren
		$CollisionShape2D.rotation = lerp_angle($body.rotation, rotation_degree, 5 *delta)
		$body.rotation = lerp_angle($body.rotation, rotation_degree, 5 *delta)
		spawn_new_track_mark.emit(Vector2.ZERO)
		acceleration_time = min(acceleration_time+delta, acceleration_duration)
		speed_scale = acceleration_time / acceleration_duration
		var speed_factor = acc_curve.sample(speed_scale)
		moving(speed_factor)
		
	else:
		acceleration_time = max(acceleration_time - delta, 0)
		speed_scale = acceleration_time / deceleration_duration
		var speed_factor = acc_curve.sample(speed_scale)
		moving(speed_factor)
	
	move_and_slide()
	
	var angle: float = rotation_direction.angle()
	
	$tower.rotation = angle + PI/2
	
	
func moving(rightspeed: float):
	#print("Rightspeed: ", rightspeed)
	velocity.x = cos($body.rotation-PI/2) * rightspeed * speed
	velocity.y = sin($body.rotation-PI/2) * rightspeed * speed


func _on_get_input_input_direction_changed(newInputDirection: Vector2) -> void:
	input_direction = newInputDirection
	
func _on_get_rotation_direction_changed(new_rotation_direction: Vector2) -> void:
	rotation_direction = new_rotation_direction
	
func get_current_rotation():
	return $body.rotation
# die input_direction ist am anfang richtig gesetzt, aber wrid dann auf 0, wahrscheinlich hängt das mit der accleration_time zusammen, dass die runter geht und die werte dann nicht mehr richtig beschleunigt werden
# 6 wird aufgerufen dh wahreinlich wird die neu direction nur einmal übergeben
