extends CharacterBody2D

@onready var rotation_degree = $body.rotation
@export var acceleration_duration = 0.5
@export var deceleration_duration = 1.5
@export var acc_curve : Curve
var acceleration_time = 0.0
var deceleration_time = 0.0
var speed = 400
var speed_scale = 0

var input_direction = Vector2.ZERO

func _physics_process(delta: float) -> void:

	rotation_degree = input_direction.angle() - PI/2
	if input_direction != Vector2.ZERO:
		#rotieren
		$CollisionShape2D.rotation = lerp_angle($body.rotation, rotation_degree, 5 *delta)
		$body.rotation = lerp_angle($body.rotation, rotation_degree, 5 *delta)
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
	
	
func moving(rightspeed: float):
	#print("Rightspeed: ", rightspeed)
	velocity.x = cos($body.rotation-PI/2) * rightspeed * speed
	velocity.y = sin($body.rotation-PI/2) * rightspeed * speed


func _on_get_input_input_direction_changed(newInputDirection: Vector2) -> void:
	input_direction = newInputDirection
	print(input_direction)

	
func get_current_rotation():
	return $body.rotation
