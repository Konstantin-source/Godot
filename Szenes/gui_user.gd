extends Control

var max_shoots_ui = 3
var current_shoots = 0
var children_array = []

@onready var bullet_tree := $Reload_Bullets
@onready var template := $Reload_Bullets/bullet

func _ready() -> void:
	for i in range(max_shoots_ui-1):
		var clone = template.duplicate()
		clone.visible = true
		$Reload_Bullets.add_child(clone)
	children_array = bullet_tree.get_children()

func just_shoot():
	current_shoots +=1
	var current_child = children_array[max_shoots_ui - current_shoots]
	current_child.modulate = Color(0,0,0,1)
	
func reset_bullets():
	current_shoots = 0
	for i in range(max_shoots_ui):
		children_array[i].modulate = Color(1,1,1,1)
		await get_tree().create_timer(0.1).timeout
