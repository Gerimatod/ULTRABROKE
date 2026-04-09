extends Node3D

var items = [{item = {name = "Molotov", weight = 2, icon = preload("res://Sprites/Items/molotov.png"), toolObj = preload("res://Scenes/tools/molotov.tscn")}, cost = 3},
{item = {name = "Slingshot", weight = 3, icon = preload("res://Sprites/Items/slingshot.png"), toolObj = preload("res://Scenes/tools/slingshot.tscn")}, cost = 5},
{item = {name = "Baseball bat", weight = 4, icon = preload("res://Sprites/Items/baseball_bat.png"), toolObj = preload("res://Scenes/tools/baseball_bat.tscn")}, cost = 6},
{item = {name = "Empty bottle", weight = 1, icon = preload("res://Sprites/Items/empty_bottle.png"), toolObj = preload("res://Scenes/tools/bottle.tscn")}, cost = 1.5},
{item = {name = "Trash can lid", weight = 5, icon = preload("res://Sprites/Items/trash_lid.png"), toolObj = preload("res://Scenes/tools/trash_can_lid.tscn")}, cost = 7}]

func generate_room(positioner,pool):
	pass

func gen_room_with_one_opening(pool):
	return generate_room($Opening,pool)

func gen_room_for_2nd_opening(pool):
	return generate_room($Opening2,pool)

func check_for_overlapping_rooms():
	return $Bounding_box.get_overlapping_areas()


func _ready() -> void:
	var item_selection = []
	for i in range(4):
		while true:
			var item = items.pick_random()
			if !item_selection.has(item):
				item_selection.append(item)
				break
	
	$Shop_shelf.item = item_selection[0].item
	$Shop_shelf.int_text = "Buy " + item_selection[0].item.name + " - $" + str(item_selection[0].cost) 
	$Shop_shelf.cost = item_selection[0].cost
	$Shop_shelf2.item = item_selection[1].item
	$Shop_shelf2.int_text = "Buy " + item_selection[1].item.name + " - $" + str(item_selection[1].cost)
	$Shop_shelf2.cost = item_selection[1].cost
	$Shop_shelf3.item = item_selection[2].item
	$Shop_shelf3.int_text = "Buy " + item_selection[2].item.name + " - $" + str(item_selection[2].cost)
	$Shop_shelf3.cost = item_selection[2].cost
