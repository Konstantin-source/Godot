extends Sprite2D

var shootPos
var reload_time_over = true
var time_since_last_shot: float = 0.0
var current_shots = 0
@export var max_shots = 5
@export var shot_delay = 0.15
@export var reload_time :float = 2
@export var bulletScene: PackedScene
@export var recoilDistance = 10
@export var recoilDuration = 0.1
@export var damage_tank = 10
@export var tower_path : NodePath
@export var shoot_point_path : NodePath
signal justShoot
signal ui_reloaded
signal reloaded

@onready var tower: Node2D = get_node(tower_path)
@onready var shootingPipeEnd: Marker2D = get_node(shoot_point_path)

var shouldShoot : bool = false

func _ready() -> void:
	var tower = $"."
	shootingPipeEnd = $rohr_Ende


func _physics_process(delta: float) -> void:
	time_since_last_shot += delta


func shoot():
	if current_shots >= max_shots:
		reload()
		return

	if time_since_last_shot <= shot_delay:
		return
	
	time_since_last_shot = 0
	current_shots += 1
	var bullet : RigidBody2D = bulletScene.instantiate() as Node2D
	#$tower/Animation.show() Mit dem Signal justShoot austauschen
	#$tower/Animation.play("default")
	
	bullet.collision_layer = 0b0100
	bullet.collision_mask = 0b0110
	
	bullet.global_position = shootingPipeEnd.global_position
	bullet.shooter_tank = self
	
	#print("Shoottt: ", shoooot.position)
	#print("Global Tank Pos: ", $".".global_position)
	#print("Position vom Geschoss: ", shoooot.position)

	bullet.rotation = $".".rotation 
	bullet.initial_scale = self.scale-Vector2(0.8,0.8)
	get_tree().current_scene.add_child(bullet)
	
	#print("Bullet Scale: ", shoooot.scale)
	#print("Self scale: ", self.scale)


	var recoil_vector = Vector2(recoilDistance, 0).rotated($".".rotation - PI/2)
	$".".global_position = lerp($".".global_position, $".".global_position-recoil_vector, 0.2)
	await  get_tree().create_timer(0.1).timeout
	$".".global_position = lerp($".".global_position, $".".global_position+recoil_vector, 0.2)
	
	
func reload():
	if reload_time_over == false:
		return
	reload_time_over = false
	var reload_timer :float = max_shots/20.0
	await get_tree().create_timer(reload_time).timeout
	#user_ui.reset_bullets()
	ui_reloaded.emit()
	await get_tree().create_timer(reload_timer).timeout
	current_shots = 0
	reload_time_over = true
	reloaded.emit()
