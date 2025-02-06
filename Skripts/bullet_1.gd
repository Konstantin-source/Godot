extends RigidBody2D

@export var Bulletspeed = 500
var count = 0
var damage = 0

var initial_scale: Vector2 

var shooter_tank: Node = null
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	damage = shooter_tank.damage_tank
	$".".lock_rotation = true
	$AnimatedSprite2D.hide()
	$GPUParticles2D.process_material.set("gravity", $".".rotation)
	$"Sprite2D".scale = initial_scale
	$Area2D/CollisionShape2D.scale = initial_scale
	$GPUParticles2D.scale = initial_scale
	$CollisionShape2D.scale = initial_scale

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var direction = Vector2.RIGHT.rotated($".".rotation-PI/2) 
	var collision_result = move_and_collide(direction * Bulletspeed * delta)
	if collision_result != null and count == 0:
		count += 1
		$AnimatedSprite2D.show()
		$GPUParticles2D.hide()
		$Sprite2D.hide()
		$AnimatedSprite2D.play("default")



func _on_area_2d_area_entered(area: Area2D) -> void:
	$AnimatedSprite2D.show()
	$AnimatedSprite2D.play("default")
	$Sprite2D.hide()
	queue_free()
	
	


func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
