extends Area3D


@export var value = 1
var isfalling = false
var velocity = Vector3.ZERO
var grav = 10

func get_dropped(amount:float, vel):
	value = amount
	velocity = vel
	if value > 1.3:
		$Texture.texture = load("res://Sprites/Items/big_money.png")
	isfalling = true





func _physics_process(delta: float) -> void:
	if isfalling == false:
		set_physics_process(false)
		return
	global_position += velocity * delta
	velocity.y -= grav * delta
	if $RayCast3D.is_colliding():
		isfalling = false
		set_physics_process(false)
		
		global_position.y += 0.5 - (global_position.distance_to($RayCast3D.get_collision_point()))


func _on_body_entered(body: Node3D) -> void:
	body.pick_up_money(value)
	queue_free()
