extends Node2D

@onready var raycasts : Array[RayCast2D] = [$unten, $untenRechts, $rechts, $obenRechts, $oben, $obenLinks, $links, $untenLinks]
var interest : Array[float] = []
var interest_scale_1 : Array[float] = [4]
var ray_length:float = 0.0

signal avoidance_vektor(vector)

func _ready() -> void:
	interest.resize(raycasts.size())
	for ray in raycasts:
		ray.collision_mask = 0b1011
		
	ray_length  =  50.0 * $".".scale.x

	
	
func _physics_process(delta: float) -> void:
	
	await get_tree().process_frame
	for i in range(raycasts.size()):
		if raycasts[i].is_colliding():
			interest[i] = (interestLevel(raycasts[i]))/ray_length
			
		else:
			interest[i] = 0.0
	
	avoidance_vektor.emit(calculate_avoidance_vector(interest))
	


func interestLevel(current_ray:RayCast2D)-> float:
	var collider = current_ray.get_collider()
	if collider != null and "global_position" in collider:
		var collider_to_player_distance : float  = (collider.global_position - $".".global_position).length()
		return collider_to_player_distance
	else:
		push_warning("Kein gültiger Collider oder keine global_position")
	return 1.0



func calculate_avoidance_vector(floats_from_rays: Array) -> Vector2:
	var directions:=[Vector2.DOWN, Vector2(1,1).normalized(), Vector2.RIGHT, Vector2(1,-1).normalized(), Vector2.UP, Vector2(-1,-1).normalized(), Vector2.LEFT, Vector2(-1,1).normalized()]
	
	var end_vector := Vector2.ZERO
	
	for i in range(8):
		end_vector += directions[i] * floats_from_rays[i]
	
	return end_vector.normalized()
