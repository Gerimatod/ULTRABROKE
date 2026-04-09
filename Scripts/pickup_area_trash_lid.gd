extends Area3D

var int_text = "Catch"



func get_interact_text():
	return int_text

func interact(pl):
	var x = pl.pick_up_item({weight = 5.0, name = "Trash can lid", icon = load("res://Sprites/Items/trash_lid.png"), toolObj = load("res://Scenes/tools/trash_can_lid.tscn")})
	print(x)
	if x == true:
		$"..".queue_free()
