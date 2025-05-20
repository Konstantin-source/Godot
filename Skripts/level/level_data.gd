extends Resource
class_name LevelData

@export var level_name: String
@export var level_scene: PackedScene
@export var max_coins: int

func _init(name: String = "", scene: PackedScene = null, coins: int = 0) -> void:
    level_name = name
    level_scene = scene
    max_coins = coins