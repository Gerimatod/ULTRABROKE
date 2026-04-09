extends Node3D

var active_enemies = []

func get_player():
	return $Player

func add_active_enemy(enemy):
	active_enemies.append(enemy)
	
	$Player.set_music(false)


func remove_active_enemy(enemy):
	
	if enemy != null:
		var i = active_enemies.find(enemy)
		if i != -1:
			active_enemies.remove_at(i)
			
	
	await get_tree().physics_frame
	
	if active_enemies.size() == 0:
		$Player.set_music(true)
