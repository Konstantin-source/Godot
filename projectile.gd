extends CharacterBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$".".lock_rotation = true
	$AnimatedSprite2D.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var slide_count = get_slide_collision_count()
	if slide_count:
		var collision = get_slide_collision(slide_count - 1)
		var collider = collision.collider
		if collider.is_in_group("barrier"):
			$AnimatedSprite2D.show()
			$Sprite2D.hide()
			await $AnimatedSprite2D.play("default")
			queue_free()
	
	

func _on_body_entered(body: Node) -> void:
	pass


func _on_area_2d_area_entered(area: Area2D) -> void:
	$AnimatedSprite2D.show()
	$AnimatedSprite2D.play("default")
	$Sprite2D.hide()
	queue_free()
	
	
