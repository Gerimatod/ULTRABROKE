extends tool

var proj = preload("res://Scenes/projectiles/rock_projectile.tscn")

@export var throwForce = 20

func primary():
	$"../../..".play_woosh()
	var rocck = proj.instantiate()
	get_tree().current_scene.add_child(rocck)
	rocck.global_position = $"../..".global_position
	rocck.get_thrown(-self.global_transform.basis.z * throwForce)
	$"../../..".hotbar[floor($"../../..".currentslot/2)] = null
	$"../../..".update_slots()
	queue_free()
