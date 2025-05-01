extends Node
var input_direction: Vector2 = Vector2.ZERO

signal inputDirectionChanged(newInputDirection)

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
		
	inputDirectionChanged.emit(input_direction)

func _on_tank_destroyed() -> void:
	death_animation.show()
	death_animation.play("death")
	for node in nodes_to_hide:
		node.hide()
	for node in nodes_to_disable:
		node.disabled = true
		
func _on_death_animation_finished() -> void:
	queue_free()