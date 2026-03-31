extends Area3D

var damage = 10
var timer = 0


func _physics_process(delta: float) -> void:
	if timer > 7:
		queue_free()
	timer += delta
	for i in get_overlapping_bodies():
		if i.get_collision_layer_value(2):
			i.take_damage(damage * delta * 0.1)
		else:
			i.take_damage(damage * delta)
