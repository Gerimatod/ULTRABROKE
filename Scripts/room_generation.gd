extends Node3D

signal is_done_generating

#little function i stole off the godot forum >:3
func dir_contents(path):
	var scene_loads = []
	
	
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				if file_name.get_extension() == "tscn":
					var full_path = path.path_join(file_name)
					scene_loads.append(load(full_path))
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	
	return scene_loads

var regular_rooms = [preload("res://Scenes/rooms/regular_rooms/basicRoom.tscn"),preload("res://Scenes/rooms/regular_rooms/basicRoom2.tscn"),preload("res://Scenes/rooms/regular_rooms/basicRoom3.tscn"),preload("res://Scenes/rooms/regular_rooms/basicRoom4.tscn")]
var two_opening_rooms = [preload("res://Scenes/rooms/2_opening_rooms/tShapedRoom.tscn"),preload("res://Scenes/rooms/2_opening_rooms/tShapedRoomEasy.tscn"),preload("res://Scenes/rooms/2_opening_rooms/tShapedRoomEasy.tscn")]
var dead_ends = [preload("res://Scenes/rooms/dead_ends/deadEndRoom.tscn")]
var boss_rooms = [preload("res://Scenes/rooms/boss_rooms/bossRoom1.tscn")]
var enterance_blocker = [preload("res://Scenes/rooms/enteranceBlocker.tscn")]
var shop = [preload("res://Scenes/rooms/special_rooms/shopRoom.tscn")]
var allrooms = regular_rooms + two_opening_rooms + dead_ends 

var main_path_length = 7
@onready var last_generated_room = $Starting_room
var last_room_type = 0



func attempt_to_generate_for_regular_room(is_next_room_forced_2_enterance_room):
	var c = 0
	while true:
		if c > 5:
			return false
		var room_to_be_generated
		var room_type_to_be_generated = 0
		var rand = randi_range(1,4)
		if rand == 3 or is_next_room_forced_2_enterance_room:
			room_to_be_generated = last_generated_room.gen_room_with_one_opening(two_opening_rooms)
			room_type_to_be_generated = 1
		else:
			room_to_be_generated = last_generated_room.gen_room_with_one_opening(regular_rooms)
			room_type_to_be_generated = 0
		await get_tree().physics_frame
		if room_to_be_generated.check_for_overlapping_rooms().size() <= 1:
			last_generated_room = room_to_be_generated
			last_room_type = room_type_to_be_generated
			return true
		else:
			room_to_be_generated.queue_free()
			c += 1



func attempt_to_generate_boss_room():
	var c = 0
	while true:
		if c > 5:
			return false
		var room_to_be_generated
		var room_type_to_be_generated = 0
		
		room_to_be_generated = last_generated_room.gen_room_with_one_opening(boss_rooms)
		room_type_to_be_generated = 0
		await get_tree().physics_frame
		if room_to_be_generated.check_for_overlapping_rooms().size() <= 1:
			last_generated_room = room_to_be_generated
			last_room_type = room_type_to_be_generated
			return true
		else:
			room_to_be_generated.queue_free()
			c += 1

func attempt_to_generate_branch(lastroom,length:int,force_shop):
	var last_branch_room = lastroom
	
	var c = 0
	
	# V Generate first branch room V
	
	while true:
		if c > 5:
			last_branch_room.gen_room_for_2nd_opening(enterance_blocker)
			if force_shop:
				return false
			return true
		
		var room_to_be_generated
		
		if length == 1:
			if force_shop:
				room_to_be_generated = last_branch_room.gen_room_for_2nd_opening(shop)
			else:
				room_to_be_generated = last_branch_room.gen_room_for_2nd_opening(dead_ends)
		else :
			room_to_be_generated = last_branch_room.gen_room_for_2nd_opening(regular_rooms)
		
		await get_tree().physics_frame
		if room_to_be_generated.check_for_overlapping_rooms().size() <= 1:
			last_branch_room = room_to_be_generated
			
			break
		else:
			room_to_be_generated.queue_free()
			c += 1
	
	# V Generate rest of branch rooms V
	
	for i in range(length-1):
		var lc = 0
		while true:
			if lc > 5:
				last_branch_room.gen_room_with_one_opening(enterance_blocker)
				if force_shop:
					return false
				return true
			
			var room_to_be_generated
			
			if i == length - 2:
				if force_shop:
					room_to_be_generated = last_branch_room.gen_room_with_one_opening(shop)
				else:
					room_to_be_generated = last_branch_room.gen_room_with_one_opening(dead_ends)
			else :
				room_to_be_generated = last_branch_room.gen_room_with_one_opening(regular_rooms)
			
			await get_tree().physics_frame
			if room_to_be_generated.check_for_overlapping_rooms().size() <= 1:
				last_branch_room = room_to_be_generated
				
				break
			else:
				room_to_be_generated.queue_free()
				lc += 1
	
	return true

func attempt_to_generate_for_2_enterance_room(is_next_room_forced_2_enterance_room,force_shop):
	
	var c = 0
	while true:
		if c > 5:
			return false
		var isSuccess = await attempt_to_generate_branch(last_generated_room, clamp(randi_range(1,5) - c, 1,5),force_shop)
		await get_tree().physics_frame
		var isSuccess2 = await attempt_to_generate_for_regular_room(is_next_room_forced_2_enterance_room)
		if isSuccess == true and isSuccess2 == true:
			return true
		else:
			return false

func on_floor_gen_fail():
	var ch = get_children()
	for child in ch:
		if child.name != "Starting_room":
			child.queue_free()
	print("room gen failed!")
	last_generated_room = $Starting_room
	last_room_type = 0
	await get_tree().create_timer(0.1).timeout
	generate_floor()

func generate_floor():
	var guaranteed_branching_path = randi_range(0,main_path_length-1)
	
	for i in range(main_path_length):
		var c = 0
		var isSucceded = false
		if last_room_type == 0:
			isSucceded = await attempt_to_generate_for_regular_room(i==guaranteed_branching_path)
		elif last_room_type == 1:
			isSucceded = await attempt_to_generate_for_2_enterance_room(i==guaranteed_branching_path, i == guaranteed_branching_path + 1)
		if isSucceded == false:
			on_floor_gen_fail()
			return
	
	if last_room_type == 1:
		var isSucceded = await attempt_to_generate_branch(last_generated_room, randi_range(1,4), guaranteed_branching_path == main_path_length)
		if isSucceded == false:
			on_floor_gen_fail()
			return
	
	var boss_room_gen_success = await attempt_to_generate_boss_room()
	if boss_room_gen_success == false:
		on_floor_gen_fail()
		return
	
	if $Starting_room.check_for_overlapping_rooms().size() > 1:
		on_floor_gen_fail()
	
	is_done_generating.emit()
	








	
