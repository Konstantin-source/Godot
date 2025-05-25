extends VBoxContainer
class_name LevelButton

signal level_selected(level_index: int)

# Use get_node_or_null to avoid crashing if nodes don't exist
var main_button: Button
var level_name_label: Label
var status_label: Label 
var coins_label: Label

var level_index: int = 0
var level_data: LevelData
var is_unlocked: bool = false
var is_completed: bool = false

func _ready() -> void:
	# Safely get node references
	main_button = get_node_or_null("MainButton")
	status_label = get_node_or_null("StatusLabel")
	
	# Only connect signals if nodes exist
	if main_button:
		main_button.pressed.connect(_on_button_pressed)
		main_button.mouse_entered.connect(_on_button_hover.bind(true))
		main_button.mouse_exited.connect(_on_button_hover.bind(false))
	
	# Check if we have parameters to set up this button
	if has_meta("params"):
		var params = get_meta("params")
		# Wait one frame to ensure all nodes are properly initialized
		await get_tree().process_frame
		setup_level_button(params.data, params.index, params.unlocked, params.completed)

func setup_level_button(data: LevelData, index: int, unlocked: bool, completed: bool) -> void:
	level_data = data
	level_index = index
	is_unlocked = unlocked
	is_completed = completed
	
	# Set level number
	if main_button:
		main_button.text = str(index + 1)
	
	# Set level name
	if level_name_label:
		level_name_label.text = data.level_name
	
	# Style button based on status
	if is_unlocked:
		if is_completed:
			if main_button:
				main_button.modulate = Color(0.4, 1.0, 0.4)  # Light green for completed
			if status_label:
				status_label.text = "✓ Completed"
				status_label.modulate = Color(0.4, 1.0, 0.4)
		else:
			if main_button:
				main_button.modulate = Color.WHITE
			if status_label:
				status_label.text = "Available"
				status_label.modulate = Color.WHITE
		if main_button:
			main_button.disabled = false
	else:
		if main_button:
			main_button.modulate = Color(0.5, 0.5, 0.5)  # Gray for locked
			main_button.disabled = true
			main_button.text = "🔒"
		if status_label:
			status_label.text = "Locked"
			status_label.modulate = Color(0.7, 0.7, 0.7)

func _on_button_pressed() -> void:
	if is_unlocked:
		level_selected.emit(level_index)

func _on_button_hover(is_hovering: bool) -> void:
	if !main_button:
		return
		
	if main_button.disabled:
		return
		
	if is_hovering:
		main_button.scale = Vector2(1.1, 1.1)
	else:
		main_button.scale = Vector2(1.0, 1.0)
