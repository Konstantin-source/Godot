extends Sprite2D

var shootPos
var reload_time_over: bool      = true
var time_since_last_shot: float = 0.0
var current_shots: int          = 0
var current_shoot_index: int = 0

@export var max_shots: int = 5
@export var shot_delay: float = 0.15
@export var reload_time :float = 2
@export var bulletScene: PackedScene
@export var recoilDistance: int = 10
@export var recoilDuration: float = 0.1
@export var damage_tank: int = 10

signal ui_reload_animation
signal ui_reload
signal just_shoot
signal init_user_ui(max_shots: int)

@export var tower: Node2D
@export var shoot_points: Array[Node2D] = []
@export var shooting_animation: AnimatedSprite2D


func _ready():
	init_user_ui.emit(max_shots)


func _physics_process(delta: float) -> void:
	time_since_last_shot += delta


func shoot() -> void:
	if current_shots >= max_shots:
		reload()
		return
	
	if time_since_last_shot <= shot_delay:
		return
	
	just_shoot.emit()
	
	time_since_last_shot = 0
	current_shots += 1
	
	shooting_animation.show()
	shooting_animation.play("default")
	
	var bullet : RigidBody2D = bulletScene.instantiate() as Node2D
	var shootingPipeEnd: Node2D = shoot_points[current_shoot_index]
	current_shoot_index = (current_shoot_index + 1) % shoot_points.size()
	bullet.global_position = shootingPipeEnd.global_position
	bullet.shooter_tank = self

	bullet.rotation = $".".rotation 
	bullet.initial_scale = self.scale-Vector2(0.8,0.8)
	get_tree().current_scene.add_child(bullet)

	if current_shots >= max_shots:
		reload()

	var recoil_vector = Vector2(recoilDistance, 0).rotated($".".rotation - PI/2)
	$".".global_position = lerp($".".global_position, $".".global_position-recoil_vector, 0.2)
	await  get_tree().create_timer(0.1).timeout
	$".".global_position = lerp($".".global_position, $".".global_position+recoil_vector, 0.2)
	
	
func reload() -> void:
	if reload_time_over == false:
		return
	reload_time_over = false
	var reload_timer :float = max_shots/20.0
	ui_reload_animation.emit()
	await get_tree().create_timer(reload_time).timeout
	ui_reload.emit()
	await get_tree().create_timer(reload_timer).timeout
	current_shots = 0
	reload_time_over = true
