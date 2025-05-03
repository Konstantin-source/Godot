extends ProgressBar
	
func _set_health(new_health: int) -> void:
	var previous_health: int = value
	value = min(max_value, new_health)

	if value < previous_health:
		$Timer.start()
	else:
		$damageBar.value = value

func init_health(initial_health: int) -> void:
	max_value = initial_health
	value = initial_health
	$damageBar.max_value = max_value
	$damageBar.value = value

func _on_timer_timeout() -> void:
	$damageBar.value = value
