extends Control

var shop_item_ui_scene = preload("res://Scenes/ui/shop_item_ui.tscn")
@onready var shop_manager: Node = $ShopManager

@onready var item_grid = $Panel/MarginContainer/VBoxContainer/ScrollContainer/ItemGrid
@onready var coin_display = $Panel/MarginContainer/VBoxContainer/HBoxContainer/CoinLabel
@onready var notification_label = $NotificationLabel
@onready var timer = $NotificationTimer

func _ready():	
	coin_display.text = "Coins: " + str(CoinCounter.get_total_coins())
	CoinCounter.coin_count_changed.connect(_update_coin_display)
	
	shop_manager.item_purchased.connect(_on_item_purchased)
	shop_manager.purchase_failed.connect(_on_purchase_failed)
	
	shop_manager.items_loaded.connect(_populate_shop_items)
	
	if not shop_manager.shop_items.is_empty():
		_populate_shop_items()

func _populate_shop_items():
	for child in item_grid.get_children():
		child.queue_free()
	
	var items = shop_manager.get_all_items()
	for item_name in items:
		var item = items[item_name]
		if item.item_is_unlocked:
			continue
		var item_ui_instance = shop_item_ui_scene.instantiate()
		item_grid.add_child(item_ui_instance)
		item_ui_instance.setup(item)
		item_ui_instance.purchase_requested.connect(_on_purchase_requested)

func _on_purchase_requested(item_name: String):
	shop_manager.purchase_item(item_name)

func _on_item_purchased(item_name: String):
	show_notification("Successfully purchased: " + item_name)
	
	for item_ui in item_grid.get_children():
		if item_ui.shop_item.item_name == item_name:
			item_ui.update_unlocked_status()
			break

func _on_purchase_failed(reason: String):
	show_notification("Purchase failed: " + reason)

func _update_coin_display(coin_count: int):
	coin_display.text = "Coins: " + str(coin_count)

func show_notification(message: String):
	notification_label.text = message
	notification_label.visible = true
	timer.start()

func _on_notification_timer_timeout():
	notification_label.visible = false

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/menu/menue.tscn")
