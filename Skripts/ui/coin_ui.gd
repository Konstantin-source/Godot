extends Label

@onready var coin_counter: Node = get_node("/root/CoinCounter")

func _ready() -> void:
	coin_counter.coin_count_changed.connect(_on_coin_count_changed)
	coin_counter.level_coins_changed.connect(_on_level_coins_changed)
	
	# Initial display
	update_display()

func _on_coin_count_changed(new_count: int) -> void:
	update_display()
	
func _on_level_coins_changed(_level_coins: int) -> void:
	update_display()
	
func update_display() -> void:
	# Display both current level coins and total coins
	var level_coins = coin_counter.get_level_coins()
	var total_coins = coin_counter.get_total_coins()
	text = "Level: " + str(level_coins) + " | Total: " + str(total_coins)