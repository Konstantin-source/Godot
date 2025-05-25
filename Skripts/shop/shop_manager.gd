extends Node

signal item_purchased(item_name: String)
signal purchase_failed(reason: String)
signal items_loaded
signal item_equipped(item_id: String, item_type: String)

var shop_items = {}
var unlocked_items = []
var equipped_items = {} # Maps item_type to item_id

func _ready():
	load_shop_items()
	
	# Use the improved registration method
	SaveManager.register_for_data(self, "_on_save_data_loaded")
	

func load_shop_items():
	var dir = DirAccess.open("res://Resources/shop/")
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var item = load("res://Resources/shop/" + file_name)
				if item is ShopItem:
					shop_items[item.item_name] = item
			file_name = dir.get_next()
	
	items_loaded.emit()

func _on_save_data_loaded(data: Dictionary):
	if data.has("unlocked_items"):
		unlocked_items = data["unlocked_items"]
		
		for item_name in unlocked_items:
			if shop_items.has(item_name):
				shop_items[item_name].item_is_unlocked = true
				item_purchased.emit(item_name)
	
	# Load equipped items by type
	if data.has("equipped_weapon"):
		equipped_items["weapon"] = data["equipped_weapon"]
	
	# Later we could add more types like:
	# if data.has("equipped_armor"):
	#     equipped_items["armor"] = data["equipped_armor"]


func purchase_item(item_name: String) -> bool:
	if not shop_items.has(item_name):
		purchase_failed.emit("Item not found")
		return false
	
	var item = shop_items[item_name]
	
	if item.item_is_unlocked:
		purchase_failed.emit("Item already unlocked")
		return false
	
	if CoinCounter.get_total_coins() < item.item_price:
		purchase_failed.emit("Not enough coins")
		return false
	
	CoinCounter._remove_total_coins(item.item_price)
	
	item.item_is_unlocked = true
	unlocked_items.append(item_name)
	
	SaveManager.save_data["unlocked_items"] = unlocked_items
	SaveManager.save_save_data()
	
	item_purchased.emit(item_name)
	return true

func equip_item(item_name: String) -> bool:
	if not shop_items.has(item_name):
		return false
	
	var item = shop_items[item_name]
	
	if not item.item_is_unlocked:
		return false
	
	if item.item_id.is_empty() or item.item_type.is_empty():
		return false
	
	# Store the equipped item by its type
	equipped_items[item.item_type] = item.item_id
	
	# Save according to item type
	if item.item_type == "weapon":
		SaveManager.save_equipped_weapon(item.item_id)
	
	# Emit signal with item_id and its type
	item_equipped.emit(item.item_id, item.item_type)
	
	return true

func get_all_items() -> Dictionary:
	return shop_items
	
func is_item_unlocked(item_name: String) -> bool:
	if not shop_items.has(item_name):
		return false
	return shop_items[item_name].item_is_unlocked

func get_equipped_item(item_type: String) -> String:
	if equipped_items.has(item_type):
		return equipped_items[item_type]
	return ""

# For backward compatibility
func get_equipped_weapon() -> String:
	return get_equipped_item("weapon")