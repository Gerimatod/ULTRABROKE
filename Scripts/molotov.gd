extends tool



var proj = preload("res://Scenes/projectiles/molotov_projectile.tscn")
@export var throwForce = 17



func primary():
	$"../../..".play_woosh()
	var btl = proj.instantiate()
	get_tree().current_scene.add_child(btl)
	btl.global_position = $"../..".global_position
	btl.get_thrown(-self.global_transform.basis.z * throwForce)
	$"../../..".hotbar[floor($"../../..".currentslot/2)] = null
	$"../../..".update_slots()
	queue_free()
