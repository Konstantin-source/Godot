extends Control

var max_shoots_ui = 0
var current_shoots = 0
var children_array = []


func _ready() -> void:
	children_array = $Reload_Bullets.get_children()
	var template = $Reload_Bullets/TextureRect
	for i in range(max_shoots_ui-1):
		var clone = template.duplicate()
		$Reload_Bullets.add_child(clone)
		

func just_shoot():
	var current_chilad = children_array[max_shoots_ui - current_shoots-1]
	current_child.modulate = Color(0,0,0,1)
	
func reset_bullets():
	for i in range(max_shoots_ui-1):
		children_array[i].modulate = Color(1,1,1,1)
	
