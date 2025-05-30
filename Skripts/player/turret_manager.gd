extends Node

var item_resources = {
	"turret_01_mk1": "res://Scenes/tank/towers/turret_01_mk1.tscn",
	"turret_01_mk2": "res://Scenes/tank/towers/turret_01_mk2.tscn",
}

@export var turret_parent: Node2D
@export var user_ui: Control
@export var player_controller: Node

func _ready() -> void:
	SaveManager.register_for_data(self, "load_equipped_items")

func load_equipped_items(save_data: Dictionary) -> void:
	if save_data.has("equipped_weapon") and not save_data["equipped_weapon"].is_empty():
		change_turret(save_data["equipped_weapon"])
	else:
		change_turret("turret_01_mk1")

func change_turret(item_id: String) -> void:
	print("Changing turret to: " + item_id)
	if not item_resources.has(item_id):
		push_error("Unknown item ID: " + item_id)
		return

	var item_scene_path = item_resources[item_id]
	var item_scene = load(item_scene_path)
	if not item_scene:
		push_error("Failed to load scene for item: " + item_id)
		return

	var item_instance = item_scene.instantiate() as Sprite2D
	if not item_instance:
		push_error("Failed to instantiate item scene: " + item_id)
		return

	if turret_parent:
		var existing_tower = turret_parent.get_node_or_null("tower")
		if existing_tower:
			existing_tower.queue_free()
		
		item_instance.name = "tower"
		item_instance.init_user_ui.connect(user_ui.init_user_ui)
		item_instance.just_shoot.connect(user_ui.just_shoot)
		item_instance.ui_reload.connect(user_ui.reset_bullets)
		item_instance.ui_reload_animation.connect(user_ui.reload_animation)
		player_controller.shoot.connect(item_instance.shoot)
		player_controller.reload.connect(item_instance.reload)
		turret_parent.add_child(item_instance)
		
		item_instance.position = Vector2.ZERO
		item_instance.rotation = 0
	else:
		push_error("Turret parent node is not set.")
