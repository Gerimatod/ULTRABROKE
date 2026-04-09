extends Area3D

var int_text = "Pick up"
var texture = preload("res://Sprites/Items/rock.png")

func get_interact_text():
	return int_text

func interact(pl):
	var x = pl.pick_up_item({weight = 5.0, name = "rock", icon = texture})
	if x == true:
		queue_free()
