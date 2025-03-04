extends ProgressBar

var health = 0 : set = _set_health


func _set_health(new_health):
	$".".modulate = Color(1,1,1,1)
	var previous_health = health
	health = min(max_value, new_health)
	value = health
	
	if health <= 0:
		queue_free()
		
	if health < previous_health:
		$Timer.start()
	else:
		$damageBar.value = health
		
	await  get_tree().create_timer(3).timeout
	$".".modulate = Color(1,1,1,0.5)


func init_health(_health):
	
	health = _health
	max_value = health
	value = health
	$damageBar.max_value = max_value
	$damageBar.value = health
	


func _on_timer_timeout() -> void:
	$damageBar.value = health
	
	
