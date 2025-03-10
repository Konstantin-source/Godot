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
var current_health = 100
var can_take_damage = true
var can_shoot = true
@export var bulletScene: PackedScene

@onready var nav_Agent := $NavigationAgent2D as NavigationAgent2D

var player: CharacterBody2D = null


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	$Node2D/healthbar.init_health(current_health)
	
	
func _physics_process(delta: float) -> void:
	if is_instance_valid(player):
		var distance_to_player = (player.global_position - global_position).length()
		var direction = to_local(nav_Agent.get_next_path_position()).normalized()
		#print(nav_Agent.get_next_path_position())
		if distance_to_player <= chase_Plaser_radius and distance_to_player >= 300:
			$body.rotation = direction.angle() + PI/2
			velocity = direction * SPEED
			move_and_slide()


		time_since_last_shoot+=delta
		if player and detection_radius >= distance_to_player:
			target_angle = (player.global_position - global_position).angle() +PI/2
			$tower.rotation = lerp_angle($tower.rotation, target_angle, delta * 5)
			if time_since_last_shoot >= shoot_speed and can_shoot:
				shoot()
		else:
			time_since_last_change +=delta
			if time_since_last_change >= idle_rotation_time:
				time_since_last_change = 0.0
				target_angle = $tower.rotation + randf_range(PI, -PI)
				
		$tower.rotation = lerp_angle($tower.rotation, target_angle, delta)
			


func health(variance: int):

	if $".":
		print(current_health)
		current_health -= variance
		if $Node2D/healthbar:
			$Node2D/healthbar._set_health(current_health)
		if current_health <= 0:
			player = null
			$CollisionShape2D.queue_free()
			$Area2D.queue_free()
			$death.show()
			SPEED = 0
			$death.play("death")
			$body.queue_free()
			$tower.queue_free()
			can_shoot = false
	
	
func shoot():
	time_since_last_shoot = 0.0
	var shoooot : RigidBody2D = bulletScene.instantiate() as Node2D
	shoooot.shooter_tank = self
	$tower/Animation.show()
	$tower/Animation.play("default")
	shoooot.position = $"tower/rohr_Ende".global_position 
	shoooot.collision_layer = 0b0010
	shoooot.collision_mask = 0b0010
	shoooot.rotation = $tower.rotation 
	shoooot.initial_scale = self.scale-Vector2(0.65,0.65)
	get_tree().current_scene.add_child(shoooot)
	
	var recoil_vector = Vector2(15, 0).rotated($tower.rotation - PI/2)
	$tower.global_position -= recoil_vector
	await get_tree().create_timer(0.3).timeout
	$tower.global_position += recoil_vector


func _on_area_2d_body_entered(body: Node2D) -> void:
	if "damage" in body and can_take_damage:
		health(body.damage)
		start_damage_cooldown()


func start_damage_cooldown():
	can_take_damage = false
	await get_tree().create_timer(0.2).timeout
	can_take_damage = true

func make_Path() -> void:
	nav_Agent.target_position = player.global_position
	nav_Agent.path_changed


func _on_death_animation_finished() -> void:
	queue_free()


func _on_pathfinding_timer_timeout() -> void:
	if is_instance_valid(player):
		make_Path()
