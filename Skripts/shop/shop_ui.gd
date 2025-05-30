extends Control

var shop_item_ui_scene = preload("res://Scenes/ui/shop_item_ui.tscn")
@onready var shop_manager: Node = $ShopManager

@onready var item_grid = $Panel/MarginContainer/VBoxContainer/ScrollContainer/ItemGrid
@onready var notification_label = $NotificationLabel
@onready var timer = $NotificationTimer

func _ready():
	shop_manager.item_purchased.connect(_on_item_purchased)
	shop_manager.purchase_failed.connect(_on_purchase_failed)
	shop_manager.item_equipped.connect(_on_item_equipped)
	
	shop_manager.items_loaded.connect(_populate_shop_items)
	
	if not shop_manager.shop_items.is_empty():
		_populate_shop_items()

func _populate_shop_items():
	for child in item_grid.get_children():
		child.queue_free()
	
	var items = shop_manager.get_all_items()
	for item_id in items:
		var item = items[item_id]
		var item_ui_instance = shop_item_ui_scene.instantiate()
		item_grid.add_child(item_ui_instance)
		item_ui_instance.setup(item)
		item_ui_instance.purchase_requested.connect(_on_purchase_requested)
		item_ui_instance.equip_requested.connect(_on_equip_requested)
	
	# Initialize equipped status for weapons
	var equipped_weapon = shop_manager.get_equipped_weapon()
	update_equipped_items_ui("weapon", equipped_weapon)

func _on_purchase_requested(item_id: String):
	shop_manager.purchase_item(item_id)

func _on_equip_requested(item_id: String):
	var item_name = shop_manager.get_item_name_from_id(item_id)
	
	if shop_manager.equip_item(item_id):
		show_notification("Successfully equipped: " + item_name)
	else:
		show_notification("Failed to equip: " + item_name)

func _on_item_purchased(item_id: String):
	var item_name = shop_manager.get_item_name_from_id(item_id)
	
	show_notification("Successfully purchased: " + item_name)
	
	for item_ui in item_grid.get_children():
		if item_ui.shop_item.item_id == item_id:
			item_ui.update_unlocked_status()
			break

func _on_purchase_failed(reason: String):
	show_notification("Purchase failed: " + reason)

func update_equipped_items_ui(item_type: String, equipped_item_id: String):
	if item_type == "weapon":
		for item_ui in item_grid.get_children():
			if item_ui.shop_item.item_type == "weapon":
				item_ui.update_equipped_status(equipped_item_id)

func _on_item_equipped(item_id: String, item_type: String):
	update_equipped_items_ui(item_type, item_id)

func show_notification(message: String):
	notification_label.text = message
	notification_label.visible = true
	timer.start()

func _on_notification_timer_timeout():
	notification_label.visible = false

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/menu/menue.tscn")
