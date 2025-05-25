extends Control

signal purchase_requested(item_name: String)
signal equip_requested(item_name: String)

var shop_item: ShopItem
var item_name_label: Label
var item_price_label: Label
var item_description_label: Label
var item_icon_texture: TextureRect
var purchase_button: Button
var equip_button: Button

func _ready():
	item_name_label = $VBoxContainer/ItemName
	item_price_label = $VBoxContainer/HBoxContainer/ItemPrice
	item_description_label = $VBoxContainer/ItemDescription
	item_icon_texture = $VBoxContainer/HBoxContainer/ItemIcon
	purchase_button = $VBoxContainer/PurchaseButton
	equip_button = $VBoxContainer/EquipButton
	
	purchase_button.pressed.connect(_on_purchase_button_pressed)
	equip_button.pressed.connect(_on_equip_button_pressed)

func setup(item: ShopItem):
	shop_item = item
	
	item_name_label.text = item.item_name
	item_price_label.text = "Price: " + str(item.item_price) + " coins"
	item_description_label.text = item.item_description
	item_icon_texture.texture = item.item_icon
	
	update_unlocked_status()

func update_unlocked_status():
	if shop_item.item_is_unlocked:
		purchase_button.disabled = true
		
		# Only show equip button for weapons
		if shop_item.item_type == "weapon":
			equip_button.visible = true
		else:
			equip_button.visible = false
	else:
		purchase_button.disabled = false
		equip_button.visible = false

func _on_purchase_button_pressed():
	purchase_requested.emit(shop_item.item_name)
	
func _on_equip_button_pressed():
	equip_requested.emit(shop_item.item_name)