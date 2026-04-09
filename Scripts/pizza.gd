extends tool

@export var food = 1.5
@export var heal = 20

func primary():
	$"../../..".take_damage(-heal)
	$"../../..".eat(food)
	$"../../..".hotbar[floor($"../../..".currentslot/2)] = null
	$"../../..".update_slots()
	queue_free()
