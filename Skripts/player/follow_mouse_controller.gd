extends Node2D

signal input_direction_changed(new_input_direction)
signal rotation_direction_changed(new_rotation_direction)

func _physics_process(_delta: float) -> void:
    var mouse_position: Vector2 = get_global_mouse_position()
    var direction: Vector2 = ($"..".global_position - mouse_position)
    
    if direction.length() < 50:
        direction = Vector2.ZERO
    else:
        direction = direction.normalized()
        
    input_direction_changed.emit(direction)
    rotation_direction_changed.emit(mouse_position - global_position)
