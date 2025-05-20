extends Node

const SAVE_FILE_PATH: String = "user://save_data.save"

var save_data: Dictionary = {
	"coin_count": 0,
	"experience": 0,
	"level": 1,
	"unlocked_items": [],
	"skill_tree_levels": {
		"movement": 0,
		"health": 0,
		"damage": 0
	}
}
var initial_save_data_loaded: bool = false
signal save_data_loaded(save_data: Dictionary)

func _ready() -> void:
	if not load_save_data():
		print("No save data found, creating new save file.")
		save_save_data()
	else:
		save_data["coin_count"] = 100
		
		initial_save_data_loaded = true
		
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
		
		initial_save_data_loaded = true
		save_data_loaded.emit(save_data)
		
		print("Save data loaded successfully.")
		return true
	else:
		print("Failed to load save data.")
		return false

func _save_new_coin_count(new_count: int) -> void:
	save_data["coin_count"] = new_count
	save_save_data()
	
func is_data_loaded() -> bool:
	return initial_save_data_loaded
	
func get_current_save_data() -> Dictionary:
	return save_data
	
# Call this from any script that needs save data
# This ensures the script will always get data, whether it's already loaded or will load in the future
func register_for_data(target_object: Object, callback_method: String) -> void:
	# If data is already loaded, call the method immediately
	if initial_save_data_loaded:
		if target_object.has_method(callback_method):
			target_object.call(callback_method, save_data)
	
	# Connect to future data loads as well
	if not save_data_loaded.is_connected(target_object.get(callback_method)):
		save_data_loaded.connect(target_object.get(callback_method))
