extends Node

@onready var progress_bar      = $ProgressBar
@onready var loading_label     = $Label

var target_scene       : String
var is_level           : bool    = false
var loading            : bool    = false
var load_game_scene    : bool    = false
var displayed_progress : float   = 0.0

func _start_loading(scene_path: String, is_level: bool=false) -> void:
	target_scene        = scene_path
	self.is_level       = is_level
	loading             = true
	displayed_progress  = 0.0
	progress_bar.value  = 0
	loading_label.text  = "Lädt... 0%"
	
	if is_level and get_tree().current_scene and get_tree().current_scene.name != "Game":
		load_game_scene = true
		ResourceLoader.load_threaded_request("res://Scenes/Game.tscn")
	
	ResourceLoader.load_threaded_request(target_scene)

func _process(_delta: float) -> void:
	if not loading:
		return

	await get_tree().create_timer(0.5).timeout

	var prog_arr = [0.0]
	var status   = ResourceLoader.load_threaded_get_status(target_scene, prog_arr)
	displayed_progress = lerp(displayed_progress, prog_arr[0] * 100.0, 0.1)
	progress_bar.value  = displayed_progress
	loading_label.text  = "Lädt... %d%%" % int(displayed_progress)

	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		return

	# Log the final status code for debugging
	print("Threaded‐load status for '%s': %d" % [target_scene, status])

	if load_game_scene:
		var status_game = ResourceLoader.load_threaded_get_status("res://Scenes/Game.tscn", prog_arr)
		print("Threaded‐load status for Game: %d" % status_game)
		if status_game != ResourceLoader.THREAD_LOAD_LOADED:
			return

	# Versuch, die PackedScene asynchron zu bekommen
	var packed_target : PackedScene = ResourceLoader.load_threaded_get(target_scene)
	if not packed_target:
		push_warning("Threaded‐load lieferte null für '%s', versuche sync load()..." % target_scene)
		# Fallback auf synchrones Laden
		packed_target = load(target_scene) if load(target_scene) is PackedScene else null
		if not packed_target:
			push_error("Fehler: Konnte '%s' weder threaded noch sync laden." % target_scene)
			loading = false
			return
		else:
			push_warning("Sync load() war erfolgreich für '%s'." % target_scene)

	var target_node : Node = packed_target.instantiate()

	if is_level:
		if load_game_scene:
			get_tree().change_scene_to_packed(
				ResourceLoader.load_threaded_get("res://Scenes/Game.tscn")
			)
			await get_tree().process_frame
			load_game_scene = false
		var game_root = get_tree().current_scene
		if not game_root:
			push_error("Kein current_scene nach Szenenwechsel zu Game.")
			loading = false
			return
		if game_root.name != "Game":
			push_error("Erwartete Game‑Szene, aber Root ist '%s'." % game_root.name)
			get_tree().change_scene_to_packed(packed_target)
		else:
			game_root.add_child(target_node)
			print("Level scene added to Game node")
	else:
		get_tree().change_scene_to_packed(packed_target)

	loading = false
	self.queue_free()
