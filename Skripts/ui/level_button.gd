extends VBoxContainer
class_name LevelButton

signal level_selected(level_index: int)

@onready var main_button: Button = $MainButton
@onready var level_name_label: Label = $LevelName

var level_index: int = 0
var level_data: LevelData
var is_unlocked: bool = false
var is_completed: bool = false

func _ready() -> void:
	
	if main_button:
		main_button.pressed.connect(_on_button_pressed)

func setup_level_button(data: LevelData, index: int, unlocked: bool, completed: bool) -> void:
	level_data = data
	level_index = index
	is_unlocked = unlocked
	is_completed = completed

	if not main_button:
		main_button = $MainButton
	if not level_name_label:
		level_name_label = $LevelName
	
	if main_button:
		main_button.text = str(index + 1)

	print("Setting up level button: " + str(index + 1) + ", Unlocked: " + str(is_unlocked) + ", Completed: " + str(is_completed))
	
	if level_name_label:
		level_name_label.text = data.level_name
	
	if is_unlocked:
		if is_completed:
			if main_button:
				main_button.modulate = Color(0.4, 1.0, 0.4)

		else:
			if main_button:
				main_button.modulate = Color.WHITE
		if main_button:
			main_button.disabled = false
	else:
		if main_button:
			main_button.modulate = Color(0.5, 0.5, 0.5)
			main_button.disabled = true
			main_button.text = "🔒"

func _on_button_pressed() -> void:
	if is_unlocked:
		level_selected.emit(level_index)