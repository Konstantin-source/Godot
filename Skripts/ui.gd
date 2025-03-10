extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	var player = get_parent().get_tree().get_nodes_in_group("player")
	player[0].connect("new_health", _health_changed)
	$CanvasLayer/healthbar.init_health(player[0].current_health)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _health_changed(changed_health):
	if changed_health >= 0:
		$CanvasLayer/healthbar._set_health(changed_health)
