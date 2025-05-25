extends Node

var item_resources = {
	"turret_01_mk1": "res://Sprites/ground_shaker_asset/Desert/Weapons/turret_01_mk1.png",
	"turret_01_mk2": "res://Sprites/ground_shaker_asset/Desert/Weapons/turret_01_mk2.png",
	"turret_01_mk3": "res://Sprites/ground_shaker_asset/Desert/Weapons/turret_01_mk3.png",
	"turret_01_mk4": "res://Sprites/ground_shaker_asset/Desert/Weapons/turret_01_mk4.png",
	"turret_02_mk1": "res://Sprites/ground_shaker_asset/Desert/Weapons/turret_02_mk1.png",
	"turret_02_mk2": "res://Sprites/ground_shaker_asset/Desert/Weapons/turret_02_mk2.png"
}

@export var turret_sprite: Sprite2D

func _ready() -> void:
	SaveManager.register_for_data(self, "load_equipped_items")

func load_equipped_items(save_data: Dictionary) -> void:
	if save_data.has("equipped_weapon") and not save_data["equipped_weapon"].is_empty():
		apply_item(save_data["equipped_weapon"], "weapon")
	else:
		apply_item("turret_01_mk1", "weapon")

func _on_item_equipped(item_id: String, item_type: String) -> void:
	apply_item(item_id, item_type)

func apply_item(item_id: String, item_type: String) -> void:
	if not item_resources.has(item_id):
		push_error("Unknown item ID: " + item_id)
		return
		
	var texture_path = item_resources[item_id]
	var texture = load(texture_path)
	
	match item_type:
		"weapon":
			if texture and turret_sprite:
				turret_sprite.texture = texture
				print("Weapon changed to: " + item_id)
			else:
				push_error("Failed to load texture for weapon: " + item_id)
		_:
			push_error("Unknown item type: " + item_type)
