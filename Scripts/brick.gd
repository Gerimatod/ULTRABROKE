extends tool

var proj = preload("res://Scenes/projectiles/brick_projectile.tscn")

@export var throwForce = 15

func primary():
	$"../../..".play_woosh()
	var briick = proj.instantiate()
	get_tree().current_scene.add_child(briick)
	briick.global_position = $"../..".global_position
	briick.get_thrown(-self.global_transform.basis.z * throwForce)
	$"../../..".hotbar[floor($"../../..".currentslot/2)] = null
	$"../../..".update_slots()
	queue_free()
