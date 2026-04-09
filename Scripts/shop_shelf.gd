extends Area3D

signal bought

@export var int_text = "Buy rock"
@export var item = {weight = 5.0, name = "rock", icon = preload("res://Sprites/Items/rock.png")}
@export var cost = 1
var droppeditem = preload("res://Scenes/dropped_item.tscn")

func get_interact_text():
	return int_text

func interact(pl):
	print("asdsasfsaf")
	var x = pl.purchase_attempt(cost)
	if x == true:
		bought.emit()
		var pickedup = pl.pick_up_item(item)
		if pickedup == false:
			var obj = droppeditem.instantiate()
			get_tree().current_scene.add_child(obj)
			obj.global_position = pl.global_position
			var cam = pl.get_cam()
			obj.get_dropped(item, -cam.global_basis.z * 5)
