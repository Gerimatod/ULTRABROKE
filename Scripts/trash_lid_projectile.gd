extends CharacterBody3D

var timer = 0
var dmg = 2.5
var isParried = false
var hitcount = 0
var canbounce = true
@onready var bounce_cd = $bounce_cooldown
@onready var particle = $impact_particle
var dropped_item = preload("res://Scenes/dropped_item.tscn")
var currvel := Vector3.ZERO
var candrop = true


func get_thrown(dir):
	currvel = dir
	velocity = dir

func parry(dir):
	isParried = true
	dmg += 0.5
	velocity = dir * currvel.length() + Vector3(0.5,0.5,0.5)
	currvel = velocity
	hitcount = 0
	


func drop():
	if candrop == false:
		return
	candrop = false
	set_process(false)
	particle.restart()
	particle.emitting = true
	var dropped = dropped_item.instantiate()
	if get_tree() == null:
		return
	get_tree().current_scene.add_child(dropped)
	dropped.global_position = global_position
	dropped.get_dropped({weight = 5.0, name = "Trash can lid", icon = load("res://Sprites/Items/trash_lid.png"), toolObj = load("res://Scenes/tools/trash_can_lid.tscn")}, -currvel.normalized() *2)
	queue_free()

func bounce():
	if canbounce == true:
		if hitcount > 1:
			drop()
		
		$Clank.play(0.5)
		timer = 0
		canbounce = false
		hitcount += 1
		particle.restart()
		particle.emitting = true
		velocity = -currvel
		currvel = -currvel
		bounce_cd.start()
		await bounce_cd.timeout
		canbounce = true

func _physics_process(delta: float) -> void:
	
	if get_slide_collision_count() >= 1 or timer > 15:
		bounce()
	rotate_y(delta * 30)
	move_and_slide()
	timer += delta
	
	



func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.get_collision_layer_value(3):
		if hitcount == 0:
			return
		body.take_damage(10)
	
	if body == self:
		return
	body.take_damage(dmg)
	bounce()
