extends CharacterBody3D

var timer = 0
var dmg = 1
var isParried = false
var dropped_item = preload("res://Scenes/dropped_item.tscn")
var thrownVel := Vector3.ZERO
var candrop = true

func get_thrown(dir):
	thrownVel = dir
	velocity = dir

func parry(dir):
	isParried = true
	dmg = 2
	velocity = dir * 30

func _physics_process(delta: float) -> void:
	if isParried == false:
		velocity.y -= 8 * delta
	move_and_slide()
	timer += delta
	if get_slide_collision_count() >= 1 or timer > 15:
		set_process(false)
		if candrop == false:
			return
		candrop = false
		var dropped = dropped_item.instantiate()
		if get_tree() == null:
			return
		get_tree().current_scene.add_child(dropped)
		dropped.global_position = global_position
		dropped.get_dropped({weight = 1.0, name = "Rock", icon = load("res://Sprites/Items/rock.png"), toolObj = load("res://Scenes/tools/rock.tscn")}, -thrownVel.normalized() *5)
		queue_free()



func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == self:
		return
	body.take_damage(dmg)
	set_process(false)
	if candrop == false:
		return
	candrop = false
	var dropped = dropped_item.instantiate()
	if get_tree() == null:
		return
	get_tree().current_scene.add_child(dropped)
	dropped.global_position = global_position
	dropped.get_dropped({weight = 1.0, name = "Rock", icon = load("res://Sprites/Items/rock.png"), toolObj = load("res://Scenes/tools/rock.tscn")}, -thrownVel.normalized() *5)
	queue_free()
	
