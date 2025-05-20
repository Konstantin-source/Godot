extends RigidBody2D

@export var Bulletspeed = 500
var count = 0
var damage = 0

var initial_scale: Vector2 
var timeInFlight : float = 0.0
var is_being_destroyed = false

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
	
	# Prevent physics interactions from causing knockback
	contact_monitor = true
	max_contacts_reported = 1
	
	# Set to a mode that doesn't push other bodies
	# In Godot 4, use freeze mode to prevent physics interactions
	freeze = true
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if is_being_destroyed:
		return
		
	timeInFlight += delta
	var direction = Vector2.RIGHT.rotated($".".rotation-PI/2)
	
	var collision = move_and_collide(direction * Bulletspeed * delta)
	
	if collision:
		_handle_collision(collision.get_collider())
	
	#Die Bullet soll nicht unnötig lang im Spiel sein - sonst kommt es zu Performance Problemen
	if timeInFlight > 25.0:
		destroy_bullet()

func _handle_collision(collider):
	if collider.is_in_group("enemy") or collider.is_in_group("player"):
		var health_node = collider.get_node_or_null("Health")
		if health_node and health_node.has_method("take_damage"):
			health_node.take_damage(damage)
		elif collider.has_method("take_damage"):
			collider.take_damage(damage)
	destroy_bullet()

func destroy_bullet() -> void:
	if is_being_destroyed:
		return
		
	is_being_destroyed = true
	linear_velocity = Vector2.ZERO

	$AnimatedSprite2D.show()
	$AnimatedSprite2D.play("default")
	$GPUParticles2D.hide()
	$Sprite2D.hide()
	
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	$CollisionShape2D.set_deferred("disabled", true)
	
	if not $AnimatedSprite2D.animation_finished.is_connected(Callable(self, "_on_animated_sprite_2d_animation_finished")):
		$AnimatedSprite2D.animation_finished.connect(Callable(self, "_on_animated_sprite_2d_animation_finished"))


func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()


func _on_body_entered(body: Node) -> void:
	print("Body entered: ", body.name)
	_handle_collision(body)


func _on_area_2d_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	print("Area entered: ", body.name)
	if body.is_in_group("enemy") or body.is_in_group("player"):
		var health_node = body.get_node_or_null("Health")
		if health_node and health_node.has_method("take_damage"):
			print("Taking damage via health node")
			health_node.take_damage(damage)
	destroy_bullet()
