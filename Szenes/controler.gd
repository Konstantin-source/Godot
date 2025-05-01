extends Node

var time_since_last_shot: float = 0.0
var current_shots = 0
var reload_time_over = true
signal shoot(isAbleTo)
@export var max_shots = 5
@export var reload_time :float = 2
#@onready var user_ui = $playerInterface.get_node("CanvasLayer/user_UI")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	shoot.emit(false)
	time_since_last_shot += delta
	if current_shots >= max_shots:
		current_shots = 0
		reload_time_over = false
		var reload_timer :float = max_shots/20.0
		await get_tree().create_timer(reload_time).timeout
		#user_ui.reset_bullets()
		await get_tree().create_timer(reload_timer).timeout
		reload_time_over = true
	
	if Input.is_action_just_pressed("fire") and reload_time_over and time_since_last_shot >= 0.15:
		shoot.emit(true)
		#user_ui.just_shoot()

	if Input.is_action_just_pressed("reload"):
		reload_time_over = false
		current_shots = 0
		var reload_timer :float = (max_shots-current_shots)/20.0
		await get_tree().create_timer(reload_time).timeout
		#user_ui.reset_bullets()
		await get_tree().create_timer(reload_timer).timeout
		reload_time_over = true
