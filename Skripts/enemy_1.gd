extends CharacterBody2D
@export var SPEED = 100.0
@export var detection_radius = 200
@export var chase_Plaser_radius = 300
@export var shoot_speed = 3.0
@export var damage_tank = 10
var time_since_last_change = 0.0
var time_since_last_shoot = 0.0
var idle_rotation_time = 3.0
var target_angle = 0.0
@export var bulletScene: PackedScene

var player: CharacterBody2D = null


func _ready() -> void:
	player = get_parent().get_node("Player")
	
	
func _physics_process(delta: float) -> void:
	if is_instance_valid(player):
		var distance_to_player = (player.global_position - global_position).length()
		var direction = Vector2(player.global_position - global_position).normalized()
		if distance_to_player <= chase_Plaser_radius and distance_to_player >= 100:
			$body.rotation = direction.angle() +PI/2
			move_and_collide(direction * SPEED * delta)
	
	
		time_since_last_shoot+=delta
		if player and detection_radius >= distance_to_player:
			target_angle = (player.global_position - global_position).angle() +PI/2
			$tower.rotation = lerp_angle($tower.rotation, target_angle, delta * 5)
			if time_since_last_shoot >= shoot_speed:
				shoot()
			
		else:
			time_since_last_change +=delta
			if time_since_last_change >= idle_rotation_time:
				time_since_last_change = 0.0
				target_angle = $tower.rotation + randf_range(PI, -PI)
				
		$tower.rotation = lerp_angle($tower.rotation, target_angle, delta)
			
	
	
	
func shoot():
	time_since_last_shoot = 0.0
	var shoooot : RigidBody2D = bulletScene.instantiate() as Node2D
	shoooot.shooter_tank = self
	$tower/Animation.show()
	$tower/Animation.play("default")
	shoooot.position = $"tower/rohr_Ende".global_position 
	
	shoooot.rotation = $tower.rotation 
	shoooot.initial_scale = self.scale-Vector2(0.65,0.65)
	get_tree().current_scene.add_child(shoooot)
	
	var recoil_vector = Vector2(15, 0).rotated($tower.rotation - PI/2)
	$tower.global_position -= recoil_vector
	await get_tree().create_timer(0.3).timeout
	$tower.global_position += recoil_vector


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("get_global_position"):
		var body_position = body.global_position
		$tower.rotation = (global_position - body_position).angle()
		
	
	
	
