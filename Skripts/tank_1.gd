extends CharacterBody2D
var speed = 400
var speed_scale = 0
@export var shoot_duration = 1
@export var bulletScene: PackedScene
@export var recoilDistance = 10
@export var recoilDuration = 0.1
@export var damage_tank = 10
@export var acc_curve : Curve
@export var acceleration_duration = 0.5
@export var deceleration_duration = 1.5
@export var reload_time = 2
@export var max_shoots = 5
@onready var rotation_degree = $body.rotation
signal shoot_signal
signal new_health(health)
var angleInRad
var shootPos
var current_health = 100
var time_since_last_shot: float = 0.0
var acceleration_time = 0.0
var deceleration_time = 0.0
var moving_var = false
var current_shoots = 0
var reload_time_over = true
@onready var user_ui = $playerInterface.get_node("CanvasLayer/user_UI")
@onready var ui_max_shoots = $playerInterface.get_node("CanvasLayer/user_UI")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ui_max_shoots.max_shoots_ui = max_shoots
	$tower/Animation.hide()
	$death.hide()
	time_since_last_shot = 1
	user_ui.max_shoots_ui = max_shoots
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	await get_tree().process_frame
	moving_var = false
	var input_direction = Vector2.ZERO
	time_since_last_shot += delta
	shootPos = $"tower/rohr_Ende".position
	velocity = Vector2() # Reset velocity

	if Input.is_action_pressed("right"):
		input_direction.x -= 1
		moving_var = true
	if Input.is_action_pressed("left"):
		input_direction.x += 1
		moving_var = true
	if Input.is_action_pressed("down"):
		input_direction.y -= 1
		moving_var = true
	if Input.is_action_pressed("up"):
		input_direction.y += 1
		moving_var = true
		
	rotation_degree = input_direction.angle() - PI/2
	
	
	
	#Umschauen
	var mouse_pos = get_global_mouse_position()
	var angle = (mouse_pos - global_position).angle()
	
	$"tower".rotation = angle + PI/2
	
	if current_shoots >= max_shoots:
		current_shoots = 0
		reload_time_over = false
		var reload_timer :float = max_shoots/20.0
		await get_tree().create_timer(reload_time).timeout
		user_ui.reset_bullets()
		print(reload_timer)
		await get_tree().create_timer(reload_timer).timeout
		reload_time_over = true
	
	#Schießen
	if Input.is_action_just_pressed("fire") and reload_time_over and time_since_last_shot >= 0.15:
		shoot()
		user_ui.just_shoot()
		
		
	#Beschleunigen
	if moving_var:
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
	
func shoot():
	time_since_last_shot = 0
	current_shoots += 1
	var shoooot : RigidBody2D = bulletScene.instantiate() as Node2D
	$tower/Animation.show()
	$tower/Animation.play("default")
	
	shoooot.collision_layer = 0b0100
	shoooot.collision_mask = 0b0100
	
	shoooot.position = $"tower/rohr_Ende".global_position 
	shoooot.shooter_tank = self
	
	#print("Shoottt: ", shoooot.position)
	#print("Global Tank Pos: ", $".".global_position)
	#print("Position vom Geschoss: ", shoooot.position)

	shoooot.rotation = $tower.rotation 
	shoooot.initial_scale = self.scale-Vector2(0.65,0.65)
	get_tree().current_scene.add_child(shoooot)
	
	#print("Bullet Scale: ", shoooot.scale)
	#print("Self scale: ", self.scale)


	var recoil_vector = Vector2(recoilDistance, 0).rotated($tower.rotation - PI/2)
	$tower.global_position = lerp($tower.global_position, $tower.global_position-recoil_vector, 0.2)
	await  get_tree().create_timer(0.2).timeout
	$tower.global_position = lerp($tower.global_position, $tower.global_position+recoil_vector, 0.2)
	
	
func health(variance: int):
	current_health -= variance
	new_health.emit(current_health)
	if current_health <= 0:
		speed = 0
		$death.show()
		$death.play("death")
		$body.hide()
		$tower.hide()
		

func moving(rightspeed: float):
	#print("Rightspeed: ", rightspeed)
	velocity.x = cos($body.rotation-PI/2) * rightspeed * speed
	velocity.y = sin($body.rotation-PI/2) * rightspeed * speed
	



func _on_area_2d_body_entered(body: Node2D) -> void:
	if "damage" in body:
		health(body.damage)


func _on_death_animation_finished() -> void:
	queue_free()
	
	
func get_current_rotation():
	return $"body".rotation
