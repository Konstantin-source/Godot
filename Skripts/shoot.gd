extends Sprite2D

var shootPos
var current_shoots = 0
var reload_time_over = true
var time_since_last_shot: float = 0.0
@export var max_shoots = 5
@export var reload_time :float = 2
@export var bulletScene: PackedScene
@export var recoilDistance = 10
@export var recoilDuration = 0.1
@export var damage_tank = 10
@export var tower_path : NodePath
@export var shoot_point_path : NodePath
signal justShoot

@onready var tower: Node2D = get_node(tower_path)
@onready var shootingPipeEnd: Marker2D = get_node(shoot_point_path)

var shouldShoot : bool = false



func _ready() -> void:
	var tower = $"."
	shootingPipeEnd = $rohr_Ende


func _physics_process(delta: float) -> void:
	if shouldShoot:
		shoot()


func shoot():
	time_since_last_shot = 0
	current_shoots += 1
	var shoooot : RigidBody2D = bulletScene.instantiate() as Node2D
	#$tower/Animation.show() Mit dem Signal justShoot austauschen
	#$tower/Animation.play("default")
	
	shoooot.collision_layer = 0b0100
	shoooot.collision_mask = 0b0110
	
	shoooot.global_position = shootingPipeEnd.global_position
	shoooot.shooter_tank = self
	
	#print("Shoottt: ", shoooot.position)
	#print("Global Tank Pos: ", $".".global_position)
	#print("Position vom Geschoss: ", shoooot.position)

	shoooot.rotation = $".".rotation 
	shoooot.initial_scale = self.scale-Vector2(0.8,0.8)
	get_tree().current_scene.add_child(shoooot)
	
	#print("Bullet Scale: ", shoooot.scale)
	#print("Self scale: ", self.scale)


	var recoil_vector = Vector2(recoilDistance, 0).rotated($".".rotation - PI/2)
	$".".global_position = lerp($".".global_position, $".".global_position-recoil_vector, 0.2)
	await  get_tree().create_timer(0.1).timeout
	$".".global_position = lerp($".".global_position, $".".global_position+recoil_vector, 0.2)
	
	
func _on_enemy_1_is_in_range(shoot: Variant) -> void:
	shouldShoot = shoot


func _on_controler_shoot(isAbleTo: Variant) -> void:
	shouldShoot = isAbleTo
