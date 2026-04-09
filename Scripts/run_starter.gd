extends Node3D

var isOnRun = true
var hasDoneRunYet = true
var days = 0

func sleep():
	if $"../Player".sleep() == false:
		return
	isOnRun = false
	hasDoneRunYet = false
	days += 1
	$"../DirectionalLight3D".light_energy = 1
	$Label3D.visible = true
	for i in $"..".get_children():
		if i is Area3D and randi_range(1,10) < 9:
			i.queue_free()

func start_run():
	if isOnRun == false and hasDoneRunYet == false:
		isOnRun = true
		hasDoneRunYet = true
		$"../Player".wait_for_room_gen()
		await get_tree().physics_frame
		visible = false
		$"../RoomGeneration".on_floor_gen_fail()
		$"../Player".global_position = $"../RoomGeneration/Starting_room/StartPos".global_position
		$"../Player".start_music()
		

func end_run():
	isOnRun = false
	visible = true
	$"../Player".stop_music()
	$"../Player".go_home()
	$"../Player".global_position = $ReturnPoint.global_position
	$"../Player".play_night_amibiance()
	$"../DirectionalLight3D".light_energy = 0.1
	$Label3D.visible = false

func _on_run_starter_body_entered(body: Node3D) -> void:
	start_run()
