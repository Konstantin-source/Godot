extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player = get_node("/root/Game/Player")
	player.connect("new_health", _health_changed)
	$healthbar.init_health(player.current_health)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _health_changed(changed_health):
	if changed_health > 0:
		$healthbar._set_health(changed_health)
