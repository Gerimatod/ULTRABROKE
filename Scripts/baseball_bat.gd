extends tool

@onready var cooldown = $Cooldown
var isOnCooldown = false

@onready var hitbox = $hitbox
@onready var anim = $AnimationPlayer
@onready var impact = $Impact




func primary():
	if isOnCooldown == true:
		return
	
	isOnCooldown = true
	
	var bodies = hitbox.get_overlapping_bodies()
	
	anim.play("batSwing")
	$"../../..".play_woosh()
	if bodies.size() > 0:
		impact.restart()
		impact.emitting = true
	
	for i in range(bodies.size()):
		if bodies[i].get_collision_layer_value(4):
			bodies[i].parry(-global_transform.basis.z)
		else:
			bodies[i].take_damage(2.5)
		
	cooldown.start()
	await cooldown.timeout
	isOnCooldown = false
	
