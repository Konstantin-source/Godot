extends CharacterBody2D
var speed = 400
@export var shoot_duration = 1
@export var bulletScene: PackedScene
@export var recoilDistance = 10
@export var recoilDuration = 0.1
var time_since_last_shot: float = 0.0
@export var damage_tank = 10

signal shoot_signal
signal new_health(health)
var angleInRad
var shootPos
var current_health = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$tower/Animation.hide()
	$death.hide()
	time_since_last_shot = 1
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	time_since_last_shot += delta
	shootPos = $"tower/rohr_Ende".position
	velocity = Vector2() # Reset velocity

	if Input.is_action_pressed("right"):
		velocity.x += 1
		$"body".rotation = PI/2
	if Input.is_action_pressed("left"):
		velocity.x -= 1
		$"body".rotation = 3*PI/2
	if Input.is_action_pressed("down"):
		velocity.y += 1
		$"body".rotation = PI
	if Input.is_action_pressed("up"):
		velocity.y -= 1
		$"body".rotation = 0
		
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		var angle = velocity.angle()
		$"body".rotation = angle + PI/2	

	var mouse_pos = get_global_mouse_position()
	var angle = (mouse_pos - global_position).angle()
	
	$"tower".rotation = angle + PI/2
	#print($".".rotation)
	velocity = velocity.normalized() * speed
	move_and_slide()
	
	if Input.is_action_just_pressed("fire") and time_since_last_shot >= shoot_duration:
		time_since_last_shot = 0
		shoot()
	
	
	
func shoot():
	var shoooot : RigidBody2D = bulletScene.instantiate() as Node2D
	$tower/Animation.show()
	$tower/Animation.play("default")
	
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
	$tower.global_position -= recoil_vector
	await get_tree().create_timer(recoilDuration).timeout
	$tower.global_position += recoil_vector
	
	
func health(variance: int):
	current_health -= variance
	new_health.emit(current_health)
	if current_health <= 0:
		$death.show()
		$death.play("death")
		$body.hide()
		$tower.hide()
		




func _on_area_2d_body_entered(body: Node2D) -> void:
	if "damage" in body:
		health(body.damage)


func _on_death_animation_finished() -> void:
	queue_free()
