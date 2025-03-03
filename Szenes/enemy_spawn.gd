extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 2.0

var current_time :float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	current_time += delta
	if current_time >= spawn_interval:
		spawn_enemy()
		current_time = 0.0
		
		
func spawn_enemy():
	if enemy_scene:
		var enemy = enemy_scene.instantiate()
		var temp_path_follow = $Path2D/PathFollow2D
		temp_path_follow.progress_ratio =  randf()
		enemy.global_position = temp_path_follow.global_position
		get_tree().current_scene.add_child(enemy)
