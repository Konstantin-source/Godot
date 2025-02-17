extends Node2D

@export var fire_rate: float = 1.0  # Sekunden zwischen den Schüssen
@export var bullet_scene:PackedScene = preload("res://Szenes/bullet1.tscn")
 # Szene für das Projektil
@export var range: float = 300.0  # Schussreichweite

var target: Node2D = null
var can_shoot: bool = true

func _ready():
	$Area2D.connect("body_entered", _on_body_entered)
	$Area2D.connect("body_exited", _on_body_exited)

func _process(delta):
	if target and is_instance_valid(target):
		look_at(target.global_position)
		if can_shoot:
			shoot()

func _on_body_entered(body):
	if body.is_in_group("player"):
		target = body

func _on_body_exited(body):
	if body == target:
		target = null

func shoot():
	can_shoot = false
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = $Marker2D.global_position
	bullet.direction = (target.global_position - global_position).normalized()
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true
