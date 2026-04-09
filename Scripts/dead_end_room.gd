extends Node3D


func generate_room(positioner,pool):
	pass

func gen_room_with_one_opening(pool):
	return generate_room($Opening,pool)

func gen_room_for_2nd_opening(pool):
	return generate_room($Opening2,pool)

func check_for_overlapping_rooms():
	return $Bounding_box.get_overlapping_areas()
