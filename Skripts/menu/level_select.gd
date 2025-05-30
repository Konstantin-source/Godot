extends Control

@onready var level_container: Control = $"."
@onready var back_button: Button = $VBoxContainer/BackButton
@onready var level_path: Path2D = $VBoxContainer/Path2D

var level_button_scene = preload("res://Scenes/ui/level_button.tscn")

func _ready() -> void:
	SaveManager.register_for_data(self, "_on_save_data_loaded")
	
	back_button.pressed.connect(_on_back_pressed)

	var l := Line2D.new()
	l.default_color = Color(1,1,1,1)
	l.width = 5
	l.z_index = 0
	
	for point in level_path.curve.get_baked_points():  
		l.add_point(point + level_path.position) 
	level_container.add_child(l)

func _on_save_data_loaded(_save_data: Dictionary) -> void:
	_setup_level_buttons()

func _setup_level_buttons() -> void:
	var save_data = SaveManager.get_current_save_data()
	var completed_levels = save_data.get("completed_levels", [])
	
	# Level 1 is always unlocked
	var unlocked_levels = [1]
	
	# Unlock next level for each completed level
	for completed_level in completed_levels:
		if completed_level + 1 <= LevelManager.levels.size():
			if not unlocked_levels.has(completed_level + 1):
				unlocked_levels.append(completed_level + 1)
	
	if !is_instance_valid(level_path):
		push_error("Path2D not found in the scene")
		return
	
	var num_levels = min(LevelManager.levels.size(), level_path.curve.point_count)
	
	for i in range(num_levels):
		var level_data = LevelManager.levels[i]
		var level_number = i + 1
		var is_unlocked = unlocked_levels.has(level_number)
		var is_completed = completed_levels.has(level_number)

		var path_point = Vector2.ZERO
		if level_path.curve != null:
			path_point = level_path.curve.get_point_position(i)

		var level_button = level_button_scene.instantiate() as LevelButton
		if level_button:
			level_button.position = path_point
			
			if level_path.position != Vector2.ZERO:
				level_button.position += level_path.position

			level_button.position.x -= level_button.size.x / 2
			
			level_button.name = "LevelPoint_" + str(i)

			level_button.setup_level_button(level_data, i, is_unlocked, is_completed)
			
			level_button.level_selected.connect(_on_level_selected)
			
			level_container.add_child(level_button)

func _on_level_selected(level_index: int) -> void:
	var level_data = LevelManager.levels[level_index]
	print("Starting level: " + level_data.level_name)
	
	var loading_label = Label.new()
	loading_label.text = "Loading " + level_data.level_name + "..."
	loading_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	loading_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	loading_label.add_theme_font_size_override("font_size", 24)
	
	loading_label.anchors_preset = Control.PRESET_CENTER
	loading_label.anchor_left = 0.5
	loading_label.anchor_top = 0.5
	loading_label.anchor_right = 0.5
	loading_label.anchor_bottom = 0.5
	loading_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	loading_label.grow_vertical = Control.GROW_DIRECTION_BOTH
	
	add_child(loading_label)
	
	LevelManager._on_level_requested(level_index)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu/menue.tscn")
