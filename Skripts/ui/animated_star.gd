extends Polygon2D

func appear():
	$AnimationPlayer.stop()
	$AnimationPlayer.play("star_appear")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("idle")
	
func set_inactive():
	modulate = Color(0.5, 0.5, 0.5, 0.5)
	$InnerStar.modulate = Color(0.5, 0.5, 0.5, 0.5)
	$Glow.modulate.a = 0.1
