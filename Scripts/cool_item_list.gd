extends Control

@onready var vbox = $ScrollContainer/VBoxContainer
@export var listItem = preload("res://Scenes/inv_list_item.tscn")
@export var is_box = false

func clear():
	for child in vbox.get_children():
		child.queue_free()
		

func add_item(item: Dictionary):
	var newListItem = listItem.instantiate()
	vbox.add_child(newListItem)
	newListItem.set_info(item)
	

func remove_list_item(item: Node):
	item.queue_free()

func drop_item(item : Dictionary, listItem : Node):
	var x = $"../../../..".drop_item(item)
	if x == true:
		remove_list_item(listItem)

func equip_item(item : Dictionary, listItem : Node):
	var x = $"../../../..".equip_item(item)
	if x == true:
		remove_list_item(listItem)

func move_item(item : Dictionary, listItem : Node):
	var x = $"../../../..".move_item(!is_box,item)
	if x == true:
		remove_list_item(listItem)
