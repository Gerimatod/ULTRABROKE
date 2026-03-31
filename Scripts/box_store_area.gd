extends Area3D

var int_text = "Store items"



func get_interact_text():
	return int_text

func interact(pl):
	get_tree().current_scene.get_player().open_box_ui($"..")
