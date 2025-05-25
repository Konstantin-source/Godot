extends Node2D
var input_direction: Vector2 = Vector2.ZERO
var rotation_direction: Vector2 = Vector2.ZERO

signal input_direction_changed(new_input_direction)
signal rotation_direction_changed(new_rotation_direction)
signal shoot()
signal reload()
signal dash()

@export var death_animation: AnimatedSprite2D
@export var nodes_to_hide: Array[Node2D] = []
@export var nodes_to_disable: Array[CollisionShape2D] = []

func _physics_process(_delta: float) -> void:
	input_direction = Vector2.ZERO
	if Input.is_action_pressed("right"):
		input_direction.x -= 1
	if Input.is_action_pressed("left"):
		input_direction.x += 1
	if Input.is_action_pressed("down"):
		input_direction.y -= 1
	if Input.is_action_pressed("up"):
		input_direction.y += 1
		
	input_direction_changed.emit(input_direction)

	if Input.is_action_just_pressed("fire"):
		shoot.emit()

	if Input.is_action_just_pressed("reload"):
		reload.emit()
	
	#Dash
	if Input.is_action_just_pressed("Dash"):
		dash.emit()
		
	rotation_direction_changed.emit(get_global_mouse_position() - global_position)

func _on_tank_destroyed() -> void:
	death_animation.show()
	SoundManager.play_soundeffect(SoundManager.Sound.EXPLOSION_TANK, 30)
	death_animation.play("death")
	for node in nodes_to_hide:
		node.hide()
	for node in nodes_to_disable:
		node.disabled = true
		
func _on_death_animation_finished() -> void:
	queue_free()
