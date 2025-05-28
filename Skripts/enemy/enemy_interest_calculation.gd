extends Node2D

enum states { IDLE, FOLLOWING, CIRCLE, DISTANCE }

@export var state : states

## Diese Variable enthält die Zeit, wie lange es dauert, bis das Enemy sich in einer bestimmten distanz wieder bewegt
@onready var raycasts : Array[RayCast2D] = [$unten, $untenRechts, $rechts, $obenRechts, $oben, $obenLinks, $links, $untenLinks]
@onready var original_speed = $"..".speed
var interest : Array[float] = []
var time_since_last_change: float = 0.0
var interest_scale_1 : Array[float] = [4]
var ray_length:float = 0.0
var current_state = 0
var time_spent : float = 0.0
var freeze_avoidance_correction :bool = false
var avoidance_correction : Vector2 = Vector2.ZERO
var initial_pattern: int  = states.IDLE
var circle_radius: float  = 0.0
var circle_angle: float   = 0.0
var circle_dir_sign: int  = 1
var direction: Vector2 = Vector2.ZERO
var random_offset : Vector2 = Vector2.ZERO
var to_player : Vector2 = Vector2.ZERO
var fov_angle : float = 120.0
var dist_to_player :float = 0.0
var target_angle: float = 0.0
var input_rotation: Vector2 = Vector2.UP
@onready var player = get_tree().get_first_node_in_group("player")
@onready var nav_Agent := $"../TracePlayer" as NavigationAgent2D
@onready var line_of_sight := $"../tower/LineOfSight" as RayCast2D


# --- Export-Variablen für das AI-Verhalten ---
##Diese Variable gibt an, wie lange es dauert, bis er sich im Idle wieder umschaut
@export var idle_rotation_time: float = 3.0
@export var chase_player_radius: float   = 300.0
@export var desired_distance: float      = 200.0
@export var circle_angular_speed: float  = 1.0
@export var idle_movement_time: float    = 3.5
@export var random_offset_pixel : int = 200
@export var turret_rotation_speed: float = 2.0
##Diese Variable gibt an, wie weit das enemy in der Line of sight sehen kann
@export var viewing_distance :float = 500.0
##Diese Variable gibt an, wie nah alle Enemys dem spieler höchstens kommen
@export var nearest_player_radius : float = 200

# ---- Signale -----
signal change_speed(new_speed)
signal inputDirectionChanged(new_input_direction)
signal input_rotation_changed(new_input_rotation)
signal shoot

func _ready() -> void:
	randomize()
	interest.resize(raycasts.size())
	for ray in raycasts:
		ray.collision_mask = 0b1011
		
	ray_length  =  50.0 * $".".scale.x
	change_state(states.IDLE)
	
	#Setzte ein Random movement Pattern
	initial_pattern = randi_range(1,3)
	
	print(initial_pattern)

	#Line of sight Init
	line_of_sight.target_position = Vector2(0, -viewing_distance)
	
	print(initial_pattern)
	change_state(initial_pattern)
	nav_Agent.set_avoidance_layer_value(1, true)
	nav_Agent.set_avoidance_mask_value(1, true)

	
	
func _physics_process(delta: float) -> void:
	# Spieler gültig?
	if not is_instance_valid(player):
		change_state(states.IDLE)
		return

	dist_to_player = (player.global_position - global_position).length()

	# State-Wechsel je nach Distanz
	if chase_player_radius >= dist_to_player or should_follow():
		change_state(initial_pattern)
	else:
		change_state(states.IDLE)

	# Wenn CIRCLE: Winkel inkrementieren
	if current_state == states.CIRCLE:
		print((global_position- nav_Agent.target_position).length())
		if (global_position- nav_Agent.target_position).length() < 200:
			circle_angle += circle_dir_sign * circle_angular_speed * delta
		

	# --- COLLISION AVOIDANCE ---
	await get_tree().process_frame  # Sicherstellen, dass alle Raycasts aktualisiert sind

	for i in range(raycasts.size()):
		if raycasts[i].is_colliding():
			interest[i] = interestLevel(raycasts[i]) / ray_length
		else:
			interest[i] = 0.0

	var avoidance_vec = calculate_avoidance_vector(interest)

	if avoidance_vec.length() > 0.0 and !freeze_avoidance_correction:
		freeze_avoidance_correction = true
		avoidance_correction = avoidance_vec
		await get_tree().create_timer(0.2).timeout
		freeze_avoidance_correction = false
	elif avoidance_vec.length() == 0.0:
		avoidance_correction = avoidance_correction.lerp(Vector2.ZERO, delta * 5.0)

	# --- NAVIGATION ZIEL ---
	to_player = player.global_position - global_position

	match current_state:
		states.FOLLOWING:
			#print("Global Pos: ", player.global_position)
			#print("Offset: ", random_offset)
			#print("avoidance: ", avoidance_correction)
			nav_Agent.target_position = player.global_position + random_offset + avoidance_correction
		states.CIRCLE:
			var offset = Vector2(cos(circle_angle), sin(circle_angle)) * circle_radius
			nav_Agent.target_position = player.global_position + offset + avoidance_correction
		states.DISTANCE:
			if dist_to_player < desired_distance:
				var away = (-to_player).normalized()
				nav_Agent.target_position = player.global_position + away * desired_distance + avoidance_correction
			elif dist_to_player > desired_distance:
				nav_Agent.target_position = player.global_position + avoidance_correction
			else:
				nav_Agent.target_position = global_position
				
		
	#  NAVIGATION AUSFÜHREN
	NavigationServer2D.agent_set_position(nav_Agent.get_rid(), global_position)
	var next_path_pos = nav_Agent.get_next_path_position()
	direction = (next_path_pos - global_position).normalized()
	NavigationServer2D.agent_set_velocity(nav_Agent.get_rid(), direction)

	var final_direction = NavigationServer2D.agent_get_velocity(nav_Agent.get_rid())
	
	#Enemys sollen langsam aus dem zu nahen Bereich wieder raus
	if dist_to_player < nearest_player_radius:
		avoidance_vec = -final_direction

	# INPUT SIGNAL EMITTEN
	if current_state != states.IDLE:
		$"../randomIdleTimer".autostart = false
		inputDirectionChanged.emit((-final_direction + 5*avoidance_correction).normalized())
	else:
		$"../randomIdleTimer".autostart = true
		
	time_since_last_change += delta
	# Wenn Spieler in Reichweite ist, Turm ausrichten und feuern
	if player and chase_player_radius <= dist_to_player and not should_follow():
		if time_since_last_change >= idle_rotation_time:
			time_since_last_change = 0.0
			var current       = $"../tower".rotation
			target_angle = current + randf_range(PI, -PI)
		var target: float = lerp_angle($"../tower".rotation, target_angle, delta * turret_rotation_speed/10)
		input_rotation = Vector2.UP.rotated(target)
		input_rotation_changed.emit(input_rotation)
		
	elif player and (chase_player_radius > dist_to_player or should_follow()):
		var current       = $"../tower".rotation
		target_angle = (player.global_position - $"..".global_position).angle() + PI / 2
		var target: float = lerp_angle(current, target_angle, delta * turret_rotation_speed*10)
		input_rotation = Vector2.UP.rotated(target)
		input_rotation_changed.emit(input_rotation)
		shoot.emit()


	
func change_state(new_state: int) -> void:
	if new_state == current_state:
		return
	exit_state(current_state)
	current_state = new_state
	enter_state(current_state)

func enter_state(state: int) -> void:
	match state:
		states.IDLE:
			$"../randomIdleTimer".start(idle_movement_time)

		states.CIRCLE:
			circle_radius   = 500#(player.global_position - global_position).length()
			circle_angle    = (global_position - player.global_position).angle()
			circle_dir_sign = (randi() % 2) * 2 - 1

		states.DISTANCE:
			# Wunsch-Abstand setzen (kannst du auch dynamisch variieren)
			desired_distance = chase_player_radius * 0.8


func exit_state(state: int) -> void:
	match state:
		states.IDLE:
			$"../randomIdleTimer".stop()
			change_speed.emit(original_speed)
		# FOLLOWING, CIRCLE, DISTANCE brauchen hier nichts

	

#Wie nah ist ein gegener an dem anderen
func interestLevel(current_ray:RayCast2D)-> float:
	var collider = current_ray.get_collider()
	if collider != null and "global_position" in collider:
		var collider_to_player_distance : float  = (collider.global_position - $".".global_position).length()
		return collider_to_player_distance
	else:
		push_warning("Kein gültiger Collider oder keine global_position")
	return 1.0


#Avoidance Vektor berechnen
func calculate_avoidance_vector(floats_from_rays: Array) -> Vector2:
	var directions:=[Vector2.DOWN, Vector2(1,1).normalized(), Vector2.RIGHT, Vector2(1,-1).normalized(), Vector2.UP, Vector2(-1,-1).normalized(), Vector2.LEFT, Vector2(-1,1).normalized()]
	
	var end_vector := Vector2.ZERO
	
	for i in range(8):
		end_vector += directions[i] * floats_from_rays[i]
	
	return end_vector.normalized()
	
	


func _on_random_idle_timer_timeout() -> void:
	if current_state != states.IDLE:
		return
	var offset_x = randi_range(-100, 100)
	var offset_y = randi_range(-100, 100)
	var random_point = global_position + Vector2(offset_x, offset_y)
	inputDirectionChanged.emit(random_point)
	change_speed.emit(80)


		
		
func make_Path() -> void:
	if is_instance_valid(player):
		nav_Agent.target_position = player.global_position
		nav_Agent.path_changed
		
		
		
func _on_random_position_timer_timeout() -> void:
	random_offset = Vector2(randi_range(-random_offset_pixel,random_offset_pixel), 
	randi_range(-random_offset_pixel,random_offset_pixel))


# Ist der Spieler oder "etwas" im sichtkegel?
func player_in_line_of_sight() -> bool:
	var direction_to_player = to_player.normalized()
	var current_view_direction = Vector2.UP.rotated($"../tower".rotation)
	var angle_to_player = rad_to_deg(acos(current_view_direction.dot(direction_to_player)))
	print("in Angle: ", angle_to_player <= fov_angle/2)
	return angle_to_player <= fov_angle/2
	
func should_follow() -> bool:
	var in_distance = dist_to_player < viewing_distance
	print("In distance: ", in_distance)
	var collider = line_of_sight.get_collider()
	var clear_sight = (collider == player or collider == null)
	
	var should_follow = player_in_line_of_sight() and in_distance and clear_sight
	print("should follow: ", should_follow)
		
	return should_follow
