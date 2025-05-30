extends Node

@onready var progress_bar 
@onready var loading_label
@onready var control_node

# Preload the game scene to avoid loading it with each level
var game_scene = preload("res://Scenes/game.tscn")

var target_scene       : String
var is_level           : bool    = false
var loading            : bool    = false
var displayed_progress : float   = 0.0
var loading_timeout    : float   = 0.0
var max_loading_time   : float   = 5.0     # Maximum time to wait at high progress
var high_progress      : float   = 95.0    # Progress threshold for timeout

func _ready():
	# Create the UI elements when the singleton is initialized
	var loading_scene = preload("res://Scenes/menu/loading_screen.tscn")
	control_node = loading_scene.instantiate()
	
	# Don't add it to the scene yet - we'll do that when needed
	progress_bar = control_node.get_node("ProgressBar")
	loading_label = control_node.get_node("Label")
	
	print("LoadingScreen singleton initialized with preloaded game scene")

func start_loading(scene_path: String, load_as_level: bool=false) -> void:
	# Check if already loading
	if loading:
		push_warning("Already loading a scene, ignoring request to load: " + scene_path)
		return
		
	# Add the loading screen to the root
	if not control_node.is_inside_tree():
		get_tree().get_root().add_child(control_node)
		
	target_scene        = scene_path
	is_level            = load_as_level
	loading             = true
	displayed_progress  = 0.0
	progress_bar.value  = 0
	loading_label.text  = "Lädt... 0%"
	
	print("Starting to load scene: " + scene_path)
	
	# We don't need to load the game scene separately anymore
	# since we've preloaded it in the _ready function
	
	ResourceLoader.load_threaded_request(target_scene)

func _process(_delta: float) -> void:
	if not loading:
		return
		
	var prog_arr = [0.0]
	var status = ResourceLoader.load_threaded_get_status(target_scene, prog_arr)
	
	# Update progress
	displayed_progress = lerp(displayed_progress, prog_arr[0] * 100.0, 0.1)
	progress_bar.value = displayed_progress
	loading_label.text = "Lädt... %d%%" % int(displayed_progress)

	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		# Still loading, continue in next frame
		return
		
	# Log the final status code for debugging
	print("Threaded‐load status for '%s': %d" % [target_scene, status])

	# Complete loading and disable loading flag first to prevent infinite loading
	loading = false
		
	# Get the packed scene
	var packed_target : PackedScene = ResourceLoader.load_threaded_get(target_scene)
	var target_node : Node = packed_target.instantiate()

	if is_level:
		# Use the preloaded game scene
		get_tree().change_scene_to_packed(game_scene)
		await get_tree().process_frame
		
		var game_root = get_tree().current_scene
		if not game_root:
			push_error("Kein current_scene nach Szenenwechsel zu Game.")
			# Remove loading screen
			if control_node.is_inside_tree():
				control_node.get_parent().remove_child(control_node)
			return
		if game_root.name != "Game":
			push_error("Erwartete Game‑Szene, aber Root ist '%s'." % game_root.name)
			get_tree().change_scene_to_packed(packed_target)
		else:
			game_root.add_child(target_node)
			print("Level scene added to Game node")
	else:
		get_tree().change_scene_to_packed(packed_target)
	
	# Remove from scene tree but don't destroy
	if control_node.is_inside_tree():
		control_node.get_parent().remove_child(control_node)
