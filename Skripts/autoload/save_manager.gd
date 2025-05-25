extends Node

const SAVE_FILE_PATH: String = "user://save_data.save"

var save_data: Dictionary = {
	"coin_count": 0,
	"experience": 0,
	"completed_levels": [],
	"unlocked_items": [],
	"equipped_weapon": "turret_01_mk1",
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

func _save_new_experience(new_experience: int) -> void:
	save_data["experience"] = new_experience
	save_save_data()

func _save_completed_level(level_number: int) -> void:
	if not save_data["completed_levels"].has(level_number):
		save_data["completed_levels"].append(level_number)
		save_save_data()
	else:
		print("Level %d already completed." % level_number)

# Generic function to save any equipped item
func save_equipped_item(item_id: String, item_type: String) -> void:
	var save_key = "equipped_" + item_type
	save_data[save_key] = item_id
	save_save_data()
	print("%s equipped and saved: %s" % [item_type.capitalize(), item_id])

# For backward compatibility and common use case
func save_equipped_weapon(weapon_id: String) -> void:
	save_equipped_item(weapon_id, "weapon")

func get_equipped_item(item_type: String) -> String:
	var save_key = "equipped_" + item_type
	if save_data.has(save_key):
		return save_data[save_key]
	return ""
	
func get_equipped_weapon() -> String:
	return get_equipped_item("weapon")
	
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
