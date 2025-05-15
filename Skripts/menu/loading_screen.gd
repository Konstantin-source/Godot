extends Node

@onready var progress_bar = $ProgressBar  # Fortschrittsbalken im UI
@onready var loading_label = $Label  # Optional: Ein "Lädt..."-Text
var target_scene: String
var loading = false  # Wird benötigt, um den Ladeprozess zu steuern
var displayed_progress = 0

func set_target_scene(new_target_scene: String):
	target_scene = new_target_scene
 
func _ready():
	start_loading(target_scene)

func start_loading(scene_path: String):
	ResourceLoader.load_threaded_request(scene_path)  # Startet das asynchrone Laden
	loading = true
	progress_bar.value = 0.0
	displayed_progress = 0.0

func _process(delta):
	if loading:
		await get_tree().create_timer(0.5).timeout
		var progress = [0.0]
		var status = ResourceLoader.load_threaded_get_status(target_scene, progress)
		
		displayed_progress = lerp(displayed_progress, progress[0] * 100, 0.1)
		progress_bar.value = displayed_progress
		loading_label.text = "Lädt... " + str(int(displayed_progress)) + "%"
		
		if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			progress_bar.value = progress[0] * 100  # Aktualisiert den Fortschritt
			loading_label.text = "Lädt... " + str(int(progress[0] * 100)) + "%"  
		elif status == ResourceLoader.THREAD_LOAD_LOADED:
			#await get_tree().create_timer(5).timeout
			var scene = ResourceLoader.load_threaded_get(target_scene)  # Fertig geladene Szene abrufen
			get_tree().change_scene_to_packed(scene)  # Szene wechseln
			loading = false  # Ladeprozess beenden
