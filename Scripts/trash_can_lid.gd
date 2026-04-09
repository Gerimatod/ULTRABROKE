extends tool

@onready var anim = $AnimationPlayer
@onready var col = $collider/CollisionShape3D
@onready var cooldown = $Cooldown
@onready var particles = $Particles
@onready var charge_area = $Charge_hit_area
var proj = preload("res://Scenes/projectiles/trash_lid_projectile.tscn")
var throwForce = 20
var chargeTimer = 0
var isOnCooldown = false
var isCharging = false

func primary():
	if isCharging == false:
		$"../../..".play_woosh()
		var thrownlid = proj.instantiate()
		get_tree().current_scene.add_child(thrownlid)
		thrownlid.global_position = $"../..".global_position
		thrownlid.get_thrown(-self.global_transform.basis.z * throwForce)
		$"../../..".hotbar[floor($"../../..".currentslot/2)] = null
		$"../../..".update_slots()
		queue_free()

func put_up():
	if isOnCooldown == true:
		return
	anim.play("put_up")
	col.disabled = false
	chargeTimer = 0
	isOnCooldown = true
	set_process(true)
	isCharging = true
	particles.emitting = true

func put_down():
	if isCharging == false:
		return
	anim.play("put_down")
	isCharging = false
	col.disabled = true
	isOnCooldown = true
	$"../../..".canMove = true
	$"../../..".velocity = Vector3.ZERO
	particles.emitting = false
	set_process(false)
	cooldown.start()
	await cooldown.timeout
	isOnCooldown = false
	
	


func secondary():
	put_up()
func secondary_release():
	put_down()
	

func on_unequip():
	put_down()
	$"../../..".canMove = true

func on_equip(item):
	isOnCooldown = true
	isCharging = true
	
	
	put_down()

func _ready() -> void:
	set_process(false)

func _process(delta: float) -> void:
	if chargeTimer > 1 or isCharging == false:
		put_down()
		return
	chargeTimer += delta
	$"../../..".velocity = -global_transform.basis.z * 17 * Vector3(1,0,1)
	$"../../..".canMove = false
	for body in charge_area.get_overlapping_bodies():
		body.take_damage(0.1)
		body.velocity = -global_basis.z * 25
