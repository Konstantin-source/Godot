extends Node2D

@export var bullet_scene: PackedScene = preload("res://Szenes/bullet1.tscn")  # Projektilszene
@export var range: float = 500.0       # Erkennungs- und Schussreichweite
@export var shoot_speed: float = 0.5  # Zeit zwischen den Schüssen
@export var damage_tank: int = 40

var time_since_last_shoot: float = 0.0
var time_since_last_change: float = 0.0
var idle_rotation_time: float = 3.0
var target_angle: float = 0.0
var current_health: int = 100
var can_take_damage: bool = true
var can_shoot: bool = true

var player: CharacterBody2D = null

func _ready() -> void:
	# Hole den Spieler (stelle sicher, dass der Pfad korrekt ist)
	player = get_parent().get_node("Player")
	
func _physics_process(delta: float) -> void:
	if is_instance_valid(player):
		var distance_to_player = (player.global_position - global_position).length()
		time_since_last_shoot += delta
		
		if distance_to_player <= range:
			# Spieler in Reichweite – Turret richtet sich auf den Spieler aus
			time_since_last_change = 0.0  # Reset idle-Zähler
			target_angle = (player.global_position - global_position).angle() + PI/2
			$tower.rotation = lerp_angle($tower.rotation, target_angle, delta * 5)
			await get_tree().create_timer(2).timeout  # Erst 0.5s warten
			
			if time_since_last_shoot >= shoot_speed and can_shoot:
				shoot()
		else:
			# Spieler außerhalb der Reichweite – zufällige Idle-Rotation
			time_since_last_change += delta
			if time_since_last_change >= idle_rotation_time:
				time_since_last_change = 0.0
				# randf_range(min, max): hier zwischen -PI und PI
				target_angle = $tower.rotation + randf_range(-PI, PI)
			$tower.rotation = lerp_angle($tower.rotation, target_angle, delta)
			
func shoot() -> void:
	time_since_last_shoot = 0
	# Erstelle ein Projektil
	var bullet = bullet_scene.instantiate() as RigidBody2D
	bullet.Bulletspeed = 1000
	# Setze Referenz zurück auf dieses Turret (falls im Projektil benötigt)
	bullet.shooter_tank = self
	
	# Spiele die Schussanimation
	$tower/schuss.show()
	$tower/schuss.play("default")
	
	# Setze die Position des Projektils an den Marker des Rohrendes
	bullet.position = $tower/rohr_Ende.global_position
	bullet.rotation = $tower.rotation
	# Passe ggf. die Skalierung des Projektils an
	bullet.scale = self.scale - Vector2(0.65, 0.65)
	
	# Füge das Projektil der aktuellen Szene hinzu
	get_tree().current_scene.add_child(bullet)
	
	# Simuliere Rückstoß: Verschiebe den Turret kurz und setze ihn zurück
	var recoil_vector = Vector2(2, 0).rotated($tower.rotation - PI/2)
	$tower.global_position -= recoil_vector
	await get_tree().create_timer(0.3).timeout
	$tower.global_position += recoil_vector
