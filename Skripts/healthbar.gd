extends ProgressBar

var health = 0 : set = _set_health


func _set_health(new_health):
	var previous_health = health
	health = min(max_value, new_health)
	value = health
	print(value)
	
	if health <= 0:
		print("TEST")
		$damageBar.value = health
		await get_tree().create_timer(.2).timeout
		queue_free()
		
	if health < previous_health:
		$Timer.start()
	else:
		$damageBar.value = health


func init_health(_health):
	health = _health
	max_value = health
	value = health
	$damageBar.max_value = max_value
	$damageBar.value = health
	


func _on_timer_timeout() -> void:
	$damageBar.value = health
	
	
