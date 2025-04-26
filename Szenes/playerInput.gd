extends Node
var input_direction = Vector2.ZERO

signal inputDirectionChanged(newInputDirection)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
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
