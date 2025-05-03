extends Node2D


@export var controlerPath : NodePath

@onready var controlerNode := get_node(controlerPath) as Node
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	return
	await get_tree().process_frame
	controlerNode.connect("new_health", _health_changed)
	$CanvasLayer/healthbar.init_health(controlerNode.current_health)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _health_changed(changed_health):
	if changed_health >= 0:
		$CanvasLayer/healthbar._set_health(changed_health)
