extends Node2D

@export var bulletScene: PackedScene = null

var target: Node2D = null

@onready var gunSprite = $AnimatedSprite2D
@onready var rayCast = $RayCast2D
@onready var reloadTimer = $RayCast2D/ReloadTimer
var damage_tanks = 10

func _ready():
	await get_tree().process_frame  # Wartet einen Frame, um sicherzustellen, dass alle Nodes geladen sind
	target = find_target()

func _physics_process(delta):
	if not target or not is_instance_valid(target):
		target = find_target()
		
	if target:
		var angle_to_target: float = global_position.direction_to(target.global_position).angle()
		rayCast.global_rotation = angle_to_target
		
		if rayCast.is_colliding():
			print("colliding")
			var collider = rayCast.get_collider()
			print(collider)
			if collider and collider.is_in_group("Player"):
				print("test")
				gunSprite.rotation = angle_to_target
				if reloadTimer.is_stopped():
					shoot()

func shoot():
	var bullet: RigidBody2D = bulletScene.instantiate()
	get_tree().current_scene.add_child(bullet)
	
	bullet.global_position = $tower/rohr_Ende.global_position
	bullet.global_rotation = rayCast.global_rotation
	
	bullet.collision_layer = 0b0010
	
	rayCast.enabled = false
	reloadTimer.start()


func find_target():
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		print("ziel gefunde")
		return players[0]
	print("kein ziel")
	return null

func _on_reload_timer_timeout() -> void:
	rayCast.enabled = true
