extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$".".lock_rotation = true
	$AnimatedSprite2D.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass
	
	



func _on_body_entered(body: Node) -> void:
	pass


func _on_area_2d_area_entered(area: Area2D) -> void:
	$AnimatedSprite2D.show()
	$AnimatedSprite2D.play("default")
	$Sprite2D.hide()
	queue_free()
	
	
