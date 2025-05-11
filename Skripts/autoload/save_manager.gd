extends Node

const SAVE_FILE_PATH: String = "user://save_data.save"

var save_data: Dictionary = {
	"coin_count": 0,
	"level": 1,
	"unlocked_items": []
}
signal save_data_loaded(save_data: Dictionary)

func _ready() -> void:
	# load with delay to ensure all nodes are ready
	await get_tree().create_timer(0.1).timeout
	if not load_save_data():
		print("No save data found, creating new save file.")
		save_save_data()
	else:
		save_data_loaded.emit(save_data)
		print(save_data)
			
func save_save_data() -> void:
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()
		print("Save data saved successfully.")
	else:
		print("Failed to save data.")
	
func load_save_data() -> bool:
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file:
		save_data = file.get_var()
		file.close()
		save_data_loaded.emit(save_data)
		print("Save data loaded successfully.")
		return true
	else:
		print("Failed to load save data.")
		return false

func _on_coin_count_changed(new_count: int) -> void:
	save_data["coin_count"] = new_count
	save_save_data()