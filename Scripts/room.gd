extends Node3D


func generate_room(positioner,pool):

	var generated_room = pool.pick_random().instantiate()
	
	
	
	add_sibling(generated_room)
	generated_room.global_position = positioner.global_position
	generated_room.rotation = positioner.global_rotation
	return generated_room

func gen_room_with_one_opening(pool):
	return generate_room($Opening,pool)

func gen_room_for_2nd_opening(pool):
	return generate_room($Opening2,pool)

func check_for_overlapping_rooms():
	return $Bounding_box.get_overlapping_areas()
