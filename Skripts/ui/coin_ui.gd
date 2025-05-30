extends Control

enum CoinUIState {
	LEVEL_COINS,
	TOTAL_COINS
}

@export var coin_ui_state: CoinUIState = CoinUIState.LEVEL_COINS
@export var label: Label

var previous_coin_count: int = 0
var initial_coin_count_loaded: bool = false

func _ready() -> void:
	if coin_ui_state == CoinUIState.LEVEL_COINS:
		CoinCounter.level_coins_changed.connect(_on_level_coins_changed)
	else:
		CoinCounter.coin_count_changed.connect(_on_coin_count_changed)

	if not initial_coin_count_loaded:
		update_display()

func _on_coin_count_changed(new_count: int) -> void:
	update_display()
	
func _on_level_coins_changed(_level_coins: int) -> void:
	update_display()
	
func update_display() -> void:
	if not initial_coin_count_loaded:
		previous_coin_count = CoinCounter.get_level_coins() if coin_ui_state == CoinUIState.LEVEL_COINS else CoinCounter.get_total_coins()
		initial_coin_count_loaded = true
		label.text = str(previous_coin_count)
		return

	var new_count = CoinCounter.get_level_coins() if coin_ui_state == CoinUIState.LEVEL_COINS else CoinCounter.get_total_coins()
	if previous_coin_count != new_count:
		animate(previous_coin_count, new_count)
	previous_coin_count = new_count


func animate(from: int, to: int) -> void:
	label.text = str(from) + " + " + str(to - from)
	await get_tree().create_timer(0.5).timeout

	for i in range(from, to + 1):
		await get_tree().create_timer(0.1).timeout
		label.text = str(i) + " + " + str(to - i)

	label.text = str(to)
