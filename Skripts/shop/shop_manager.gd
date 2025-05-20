extends Node

signal item_purchased(item_name: String)
signal purchase_failed(reason: String)
signal items_loaded

var shop_items = {}
var unlocked_items = []

@onready var coin_counter = get_node("/root/CoinCounter")
@onready var save_manager = get_node("/root/SaveManager")

func _ready():
	load_shop_items()
	
	# Use the improved registration method
	save_manager.register_for_data(self, "_on_save_data_loaded")
	

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
		

func purchase_item(item_name: String) -> bool:
	if not shop_items.has(item_name):
		purchase_failed.emit("Item not found")
		return false
	
	var item = shop_items[item_name]
	
	if item.item_is_unlocked:
		purchase_failed.emit("Item already unlocked")
		return false
	
	if coin_counter.get_total_coins() < item.item_price:
		purchase_failed.emit("Not enough coins")
		return false
	
	coin_counter._remove_total_coins(item.item_price)
	
	item.item_is_unlocked = true
	unlocked_items.append(item_name)
	
	save_manager.save_data["unlocked_items"] = unlocked_items
	save_manager.save_save_data()
	
	item_purchased.emit(item_name)
	return true

func get_all_items() -> Dictionary:
	return shop_items
	
func is_item_unlocked(item_name: String) -> bool:
	if not shop_items.has(item_name):
		return false
	return shop_items[item_name].item_is_unlocked