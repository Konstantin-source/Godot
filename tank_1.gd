extends CharacterBody2D
var speed = 400

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	velocity = Vector2() # Reset velocity

	if Input.is_action_pressed("right"):
		velocity.x += 1
		$"body".rotation = PI/2
	if Input.is_action_pressed("left"):
		velocity.x -= 1
		$"body".rotation = 3*PI/2
	if Input.is_action_pressed("down"):
		velocity.y += 1
		$"body".rotation = PI
	if Input.is_action_pressed("up"):
		velocity.y -= 1
		$"body".rotation = 0
		
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		var angle = velocity.angle()
		$"body".rotation = angle + PI/2	

	var mouse_pos = get_global_mouse_position()
	var angle = (mouse_pos - global_position).angle()
	
	$"tower".rotation = angle + PI/2
	print($".".rotation)
	velocity = velocity.normalized() * speed
	move_and_slide()
