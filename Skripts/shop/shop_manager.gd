extends Node

signal item_purchased(item_id: String)
signal purchase_failed(reason: String)
signal items_loaded
signal item_equipped(item_id: String, item_type: String)

var shop_items = {}
var unlocked_items = []
var equipped_items = {}

func _ready():
	load_shop_items()
	
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
					shop_items[item.item_id] = item
			file_name = dir.get_next()
	
	items_loaded.emit()

func _on_save_data_loaded(data: Dictionary):
	if data.has("unlocked_items"):
		unlocked_items = data["unlocked_items"]
		
		for item_id in unlocked_items:
			if shop_items.has(item_id):
				shop_items[item_id].item_is_unlocked = true
				item_purchased.emit(item_id)
	
	if data.has("equipped_weapon"):
		equipped_items["weapon"] = data["equipped_weapon"]


func purchase_item(item_id: String) -> bool:
	if not shop_items.has(item_id):
		purchase_failed.emit("Item not found")
		return false
	
	var item = shop_items[item_id]
	
	if item.item_is_unlocked:
		purchase_failed.emit("Item already unlocked")
		return false
	
	if CoinCounter.get_total_coins() < item.item_price:
		purchase_failed.emit("Not enough coins")
		return false
	
	CoinCounter._remove_total_coins(item.item_price)
	
	item.item_is_unlocked = true
	unlocked_items.append(item_id)
	
	SaveManager.save_data["unlocked_items"] = unlocked_items
	SaveManager.save_save_data()
	
	item_purchased.emit(item_id)
	return true

func equip_item(item_id: String) -> bool:
	if not shop_items.has(item_id):
		return false
	
	var item = shop_items[item_id]
	
	if not item.item_is_unlocked:
		return false
	
	if item.item_id.is_empty() or item.item_type.is_empty():
		return false
	
	equipped_items[item.item_type] = item.item_id
	
	if item.item_type == "weapon":
		SaveManager.save_equipped_weapon(item.item_id)
	
	item_equipped.emit(item.item_id, item.item_type)
	
	return true

func get_all_items() -> Dictionary:
	return shop_items
	
func is_item_unlocked(item_id: String) -> bool:
	if not shop_items.has(item_id):
		return false
	return shop_items[item_id].item_is_unlocked

func get_equipped_item(item_type: String) -> String:
	if equipped_items.has(item_type):
		return equipped_items[item_type]
	return ""

func get_equipped_weapon() -> String:
	return get_equipped_item("weapon")
	
func get_item_name_from_id(item_id: String) -> String:
	if shop_items.has(item_id):
		return shop_items[item_id].item_name
	return ""