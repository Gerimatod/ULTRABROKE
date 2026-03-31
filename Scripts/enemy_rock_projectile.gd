extends CharacterBody3D

var timer = 0
var dmg = 10
var isParried = false

func get_thrown(dir):

	velocity = dir

func parry(dir):
	dmg = 2
	set_collision_mask_value(3,false)
	set_collision_mask_value(2,true)
	velocity = dir * 30
	isParried = true


func _physics_process(delta: float) -> void:
	if isParried == false:
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
