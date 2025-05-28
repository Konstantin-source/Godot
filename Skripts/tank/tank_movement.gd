extends CharacterBody2D

@onready var rotation_degree = $body.rotation
@export var acceleration_duration: float = 0.5
@export var deceleration_duration: float = 1.5
@export var acc_curve : Curve
@export var acceleration_time: float = 0.0
@export var speed: int               = 200
@export var track_marks_left_position : Marker2D
@export var track_marks_right_position: Marker2D
@export var track_marks_sprite_path: NodePath 
@export var track_marks_distance: int
@export var dash_time = .1
@export var dash_timeout :float  = 3

@onready var track_marks_sprite = get_node(track_marks_sprite_path) as Sprite2D
@onready var street_tiles = get_tree().get_first_node_in_group("ground")

var deceleration_time: float = 0.5
var speed_scale: float         = 0
var can_dash : bool = true

var input_direction: Vector2    = Vector2.ZERO
var rotation_direction: Vector2 = Vector2.ZERO
var last_track_position_left: Vector2 = Vector2.ZERO
var last_track_position_right: Vector2 = Vector2.ZERO
var turn_speed : int = 10

signal is_dashing()

func _physics_process(delta: float) -> void:
	if (!is_instance_valid($body)):
		return
		
	#Track Marks auf der Straße entfernen
	
	var coords = street_tiles.local_to_map(street_tiles.to_local(global_position))
	var tile_data = street_tiles.get_cell_tile_data(coords)

	if tile_data != null:
		var value = tile_data.get_custom_data("street")
		if tile_data.has_custom_data("street"):
			var tile_type = tile_data.get_custom_data("street")
			if tile_type == 1:
				track_marks_sprite.modulate = Color(0.1,0.1,0.1,0.1)
			else:
				track_marks_sprite.modulate = Color(1,1,1,0.3)


	rotation_degree = input_direction.angle() - PI/2
	if input_direction != Vector2.ZERO:
		#rotieren
		$CollisionShape2D.rotation = lerp_angle($body.rotation, rotation_degree, turn_speed *delta)
		$body.rotation = lerp_angle($body.rotation, rotation_degree, turn_speed *delta)
		#var track_mark_direction = Vector2(cos($body.rotation), sin($body.rotation))
		make_track_marks($body.rotation)
		acceleration_time = min(acceleration_time+delta, acceleration_duration)
		speed_scale = acceleration_time / acceleration_duration
		var speed_factor = acc_curve.sample(speed_scale)
		moving(speed_factor)
		
	else:
		acceleration_time = max(acceleration_time - delta, 0)
		speed_scale = acceleration_time / deceleration_duration
		var speed_factor = acc_curve.sample(speed_scale)
		
		moving(speed_factor)
	
	move_and_slide()
	
	var angle: float = rotation_direction.angle()
	
	$tower.rotation = angle + PI/2
	
	
func moving(rightspeed: float):
	#print("Rightspeed: ", rightspeed)
	velocity.x = cos($body.rotation-PI/2) * rightspeed * speed
	velocity.y = sin($body.rotation-PI/2) * rightspeed * speed


func _on_get_input_input_direction_changed(newInputDirection: Vector2) -> void:
	input_direction = newInputDirection
	
func _on_get_rotation_direction_changed(new_rotation_direction: Vector2) -> void:
	rotation_direction = new_rotation_direction
	
func get_current_rotation():
	return $body.rotation
	

# die input_direction ist am anfang richtig gesetzt, aber wrid dann auf 0, wahrscheinlich hängt das mit der accleration_time zusammen, dass die runter geht und die werte dann nicht mehr richtig beschleunigt werden
# 6 wird aufgerufen dh wahreinlich wird die neu direction nur einmal übergeben


func dash() -> void:
	if can_dash:
		can_dash = false
		speed = speed * 2
		is_dashing.emit()
		await get_tree().create_timer(dash_time).timeout
		speed = speed / 2
		await get_tree().create_timer(dash_timeout).timeout
		can_dash = true

func make_track_marks(direction: float):
	# wird eingebunden, indem man zwei Marker2D und einen Sprite2d an den body häng (An den Markern spawnen die neuen spuren) 
	# damit nicht unendlich of dupliziert wird 
	if ((track_marks_left_position.global_position - last_track_position_left).length() > track_marks_distance):
		var duplicate_left = track_marks_sprite.duplicate()
		# an die linke Kette setzen 
		duplicate_left.global_position = track_marks_left_position.global_position
		last_track_position_left = duplicate_left.global_position 
		
		duplicate_left.rotation = direction
		
		get_tree().current_scene.add_child(duplicate_left)
		#verschwinden lassen, könnten wir noch öfter benutzen 
		var tween_left = get_tree().create_tween()
		tween_left.tween_property(duplicate_left, "modulate:a", 0.0, 5.0)
		tween_left.tween_callback(Callable(duplicate_left, "queue_free"))
		
	if ((track_marks_right_position.global_position - last_track_position_right).length() > track_marks_distance):
		var duplicate_right= track_marks_sprite.duplicate()
		
		duplicate_right.global_position = track_marks_right_position.global_position
		last_track_position_right = duplicate_right.global_position 
		
		duplicate_right.rotation = direction
		
		get_tree().current_scene.add_child(duplicate_right)
		
		var tween_right = get_tree().create_tween()
		tween_right.tween_property(duplicate_right, "modulate:a", 0.0, 5.0)
		tween_right.tween_callback(Callable(duplicate_right, "queue_free"))
	


	


func change_speed(new_speed: Variant) -> void:
	speed = new_speed
