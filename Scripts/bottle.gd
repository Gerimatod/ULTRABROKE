extends tool

@onready var cooldown = $Cooldown
var isOnCooldown = false
var isBroken = false
@onready var hitbox = $hitbox
@onready var brokenhitbox = $brokenHitbox
var proj = preload("res://Scenes/projectiles/bottle_projectile.tscn")
@export var throwForce = 17
var breakchance = 0

func on_equip(iteminfo : Dictionary):
	
	if iteminfo.has("isBroken"):
		if iteminfo["isBroken"] == true:
			isBroken = true

func primary():
	if isOnCooldown == true:
		return
	
	
	var bodies = hitbox.get_overlapping_bodies()
	var brokenBodies = brokenhitbox.get_overlapping_bodies()
	
	
	for i in range(bodies.size()):
		if isBroken == true:
			bodies[i].take_damage(2)
			
		elif randi_range(0,100) < breakchance:
			
			bodies[i].take_damage(3)
			isBroken = true
			$"../../..".hotbar[floor($"../../..".currentslot/2)]["isBroken"] = true
			$MeshInstance3D/GPUParticles3D.emitting = true
		else :
			bodies[i].take_damage(1)
			breakchance += randi_range(3,15)
	$AnimationPlayer.play("bottleSwing")
	isOnCooldown = true
	cooldown.start()
	await cooldown.timeout
	isOnCooldown = false
	
func secondary():
	$"../../..".play_woosh()
	var btl = proj.instantiate()
	get_tree().current_scene.add_child(btl)
	btl.global_position = $"../..".global_position
	btl.get_thrown(-self.global_transform.basis.z * throwForce)
	$"../../..".hotbar[floor($"../../..".currentslot/2)] = null
	$"../../..".update_slots()
	queue_free()
