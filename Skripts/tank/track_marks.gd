extends Node2D
@onready var original_sprite: Sprite2D = $"."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	

func _on_spawn_new_track_mark(position: Vector2) -> void:
	print(23)
	var new_sprite := original_sprite.duplicate()
	new_sprite.position = position
	get_tree().current_scene.add_child(new_sprite)
