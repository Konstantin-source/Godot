extends SubViewport

@onready var camera = $Camera2D
@onready var player = get_tree().get_first_node_in_group("player")
@onready var icon_map = $"../player_map"

func _ready() -> void:
	world_2d = get_tree().root.world_2d

func _physics_process(delta: float) -> void:
	
	camera.position = get_tree().get_first_node_in_group("player").position
	icon_map.rotation = player.get_current_rotation() + deg_to_rad(24.0)
