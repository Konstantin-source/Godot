extends Sprite2D

var shootPos
var reload_time_over: bool      = true
var time_since_last_shot: float = 0.0
var current_shots: int          = 0
@export var max_shots: int = 5
@export var shot_delay: float = 0.15
@export var reload_time :float = 2
@export var bulletScene: PackedScene
@export var recoilDistance: int = 10
@export var recoilDuration: float = 0.1
@export var damage_tank: int = 10
@export var tower_path : NodePath
@export var shoot_point_path : NodePath
@export var shoot_animation_path: NodePath
signal ui_reloaded
signal reloaded
@export var userUiPath : NodePath

signal ui_reload_animation
signal ui_reload
signal justShoot

@onready var user_ui = get_node_or_null(userUiPath)
@onready var tower: Node2D = get_node(tower_path)
@onready var shootingPipeEnd: Marker2D = get_node(shoot_point_path)
@onready var shootingAnimation: AnimatedSprite2D = get_node (shoot_animation_path)


var shouldShoot : bool = false


func _ready():
	await get_tree().process_frame
	shootingPipeEnd = $rohr_Ende
	if user_ui:
		user_ui.max_shoots_ui = max_shots
		print(user_ui)
	else:
		push_warning("user UI wurde noch nicht geladen")


func _physics_process(delta: float) -> void:
	time_since_last_shot += delta


func shoot() -> void:
	if current_shots >= max_shots:
		reload()
		return
	

	if time_since_last_shot <= shot_delay:
		return
	
	justShoot.emit()
	
	time_since_last_shot = 0
	current_shots += 1
	
	var bullet : RigidBody2D = bulletScene.instantiate() as Node2D
	shootingAnimation.show()
	shootingAnimation.play("default")
	#$tower/Animation.show() Mit dem Signal justShoot austauschen
	#$tower/Animation.play("default")
	
	#bullet.collision_layer = 0b0100
	bullet.collision_layer = 0b10100
	bullet.collision_mask = 0b0110
	
	bullet.global_position = shootingPipeEnd.global_position
	bullet.shooter_tank = self
	
	#print("Shoottt: ", shoooot.position)
	#print("Global Tank Pos: ", $".".global_position)
	#print("Position vom Geschoss: ", shoooot.position)

	bullet.rotation = $".".rotation 
	bullet.initial_scale = self.scale-Vector2(0.8,0.8)
	get_tree().current_scene.add_child(bullet)
	if current_shots >= max_shots:
		reload()
	
	#print("Bullet Scale: ", shoooot.scale)
	#print("Self scale: ", self.scale)


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
