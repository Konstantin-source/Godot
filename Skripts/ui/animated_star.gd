extends Sprite2D

@onready var animation_player = get_parent().get_node("AnimationPlayer")

func appear():
	animation_player.stop()
	animation_player.play("star_appear")
	await animation_player.animation_finished
	animation_player.play("idle")
	
func set_inactive():
	modulate = Color(0.5, 0.5, 0.5, 0.5)
