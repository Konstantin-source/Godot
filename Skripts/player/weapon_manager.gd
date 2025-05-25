extends Node

# Paths to the different item resources in the game
var item_resources = {
	# Weapon items
	"turret_01_mk1": "res://Sprites/ground_shaker_asset/Desert/Weapons/turret_01_mk1.png",
	"turret_01_mk2": "res://Sprites/ground_shaker_asset/Desert/Weapons/turret_01_mk2.png",
	"turret_01_mk3": "res://Sprites/ground_shaker_asset/Desert/Weapons/turret_01_mk3.png",
	"turret_01_mk4": "res://Sprites/ground_shaker_asset/Desert/Weapons/turret_01_mk4.png",
	"turret_02_mk1": "res://Sprites/ground_shaker_asset/Desert/Weapons/turret_02_mk1.png",
	"turret_02_mk2": "res://Sprites/ground_shaker_asset/Desert/Weapons/turret_02_mk2.png",
	
	# Can add other item types here in the future, e.g.:
	# "tank_body_green": "res://Sprites/ground_shaker_asset/Desert/Bodies/body_green.png",
	# "special_tracks": "res://Sprites/ground_shaker_asset/Desert/Tracks/track_special.png",
}

# Reference to the player's turret sprite
@export var turret_sprite: Sprite2D

func _ready() -> void:
	# Register for save data to load the equipped items
	SaveManager.register_for_data(self, "load_equipped_items")
	
	# Connect to shop manager to handle item changes from purchasing new items
	if get_tree().root.has_node("/root/ShopManager"):
		var shop_manager = get_tree().root.get_node("/root/ShopManager")
		shop_manager.item_equipped.connect(_on_item_equipped)

func load_equipped_items(save_data: Dictionary) -> void:
	# Handle weapon type
	if save_data.has("equipped_weapon") and not save_data["equipped_weapon"].is_empty():
		apply_item(save_data["equipped_weapon"], "weapon")
	else:
		# Default to the first weapon if none is equipped
		apply_item("turret_01_mk1", "weapon")
	
	# In the future, can add more item types:
	# if save_data.has("equipped_body") and not save_data["equipped_body"].is_empty():
	#     apply_item(save_data["equipped_body"], "body")

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
		# Add more item types here in the future:
		# "body":
		#     if texture and body_sprite:
		#         body_sprite.texture = texture
		#         print("Body changed to: " + item_id)
		_:
			push_error("Unknown item type: " + item_type)
