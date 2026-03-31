extends Node3D

var box_contents = []
var weight = 0

var box_max_weight = 10

func add_to_box(item):
	weight = 0
	for i in box_contents:
		weight += i.weight
	
	if weight + item.weight > box_max_weight:
		return false
	else:
		box_contents.append(item)
		update_weight()
		return true
	

func update_weight():
	weight = 0
	for i in box_contents:
		weight += i.weight

func _ready() -> void:
	update_weight()




func _on_sleep_area_body_entered(body: Node3D) -> void:
	$"../..".sleep()
	get_tree().current_scene.get_player().sleep()
