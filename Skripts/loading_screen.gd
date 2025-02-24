extends Node

@onready var progress_bar = $ProgressBar  # Fortschrittsbalken im UI
@onready var loading_label = $Label  # Optional: Ein "Lädt..."-Text
var target_scene: String
var loading = false  # Wird benötigt, um den Ladeprozess zu steuern

func set_target_scene(new_target_scene: String):
	target_scene = new_target_scene
 
func _ready():
	start_loading(target_scene)

func start_loading(scene_path: String):
	print("cenepath:" + scene_path )
	ResourceLoader.load_threaded_request(scene_path)  # Startet das asynchrone Laden
	loading = true
	progress_bar.value = 0.0
	print("es wird start_loading komplett aufgerufen")

func _process(delta):
	print("process ist aufgerufen ")
	if loading:
		var progress = []
		var status = ResourceLoader.load_threaded_get_status(target_scene, progress)
		print("if loading ist aufgerufen" + target_scene)
		
		
		if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			progress_bar.value = progress[0] * 100  # Aktualisiert den Fortschritt
			loading_label.text = "Lädt... " + str(int(progress[0] * 100)) + "%"  
			print("if status")
		elif status == ResourceLoader.THREAD_LOAD_LOADED:
			var scene = ResourceLoader.load_threaded_get(target_scene)  # Fertig geladene Szene abrufen
			get_tree().change_scene_to_packed(scene)  # Szene wechseln
			loading = false  # Ladeprozess beenden
			print("alles aufgerufen")
