extends Node2D
var input_direction: Vector2 = Vector2.ZERO
var rotation_direction: Vector2 = Vector2.ZERO

var is_destroyed: bool = false

signal input_direction_changed(new_input_direction)
signal rotation_direction_changed(new_rotation_direction)
signal shoot()
signal reload()
signal dash()

@export var death_animation: AnimatedSprite2D
@export var nodes_to_hide: Array[Node2D] = []
@export var nodes_to_disable: Array[CollisionShape2D] = []

@onready var level_manager = get_node("/root/LevelManager")

func _physics_process(_delta: float) -> void:
	if is_destroyed:
		return

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
		print("reload gedrückt")
	
	#Dash
	if Input.is_action_just_pressed("Dash"):
		dash.emit()
		
	rotation_direction_changed.emit(get_global_mouse_position() - global_position)

func _on_tank_destroyed() -> void:
	if is_destroyed:
		return
	is_destroyed = true

	death_animation.show()
	death_animation.play("death")
	for node in nodes_to_hide:
		node.hide()
	for node in nodes_to_disable:
		node.disabled = true
		
	# Show defeat screen after a short delay
	await get_tree().create_timer(1.5).timeout
	if level_manager and level_manager.has_method("show_defeat_screen"):
		level_manager.show_defeat_screen()
		
func _on_death_animation_finished() -> void:
	# Don't queue_free() immediately to allow defeat screen to show
	# Delay destruction to keep the death scene visible
	await get_tree().create_timer(3.0).timeout
	queue_free()
