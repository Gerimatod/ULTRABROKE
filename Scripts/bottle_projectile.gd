extends CharacterBody3D

var timer = 0
var dmg = 1


var fire = preload("res://Scenes/fire.tscn")
var thrownVel := Vector3.ZERO
var candrop = true

func get_thrown(dir):
	thrownVel = dir
	velocity = dir

func parry(dir):
	queue_free()

func _physics_process(delta: float) -> void:
	velocity.y -= 8 * delta
	move_and_slide()
	timer += delta
	if get_slide_collision_count() >= 1 or timer > 15:
		
		queue_free()



func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == self:
		return
	body.take_damage(dmg)
	queue_free()
