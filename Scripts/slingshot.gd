extends tool

var proj = preload("res://Scenes/projectiles/rock_projectile.tscn")

@export var throwForce = 15
@onready var raycast = $FastCast
@onready var anim = $AnimationPlayer
var timer = 0.0
var has_ammo = false

func _ready() -> void:
	set_process(false)
	check_for_ammo()

func launchProj(dmg):
	var rocck = proj.instantiate()
	get_tree().current_scene.add_child(rocck)
	rocck.global_position = $"../..".global_position
	rocck.dmg = dmg
	rocck.get_thrown(-self.global_transform.basis.z * timer * 20)
	
func hitscan():
	if raycast.is_colliding():
		var body = raycast.get_collider()
		if body.get_collision_layer_value(2):
			body.take_damage(timer * 2)
	$StronkParticle.restart()
	$StronkParticle.emitting = true
	$HitscanVisual.visible = true
	$Rock.visible = false
	await get_tree().create_timer(0.05).timeout
	$HitscanVisual.visible = false
	$Rock.visible = true

func check_for_ammo():
	for i in $"../../..".hotbar:
		if i != null:
			if i.has("name"):
				if i.name == "Rock":
					has_ammo = true
					anim.play("put_on_rock")
					return
	

func charge(dt):
	timer = clamp(timer + dt, 0, 1.5)
	$CanvasLayer/TextureProgressBar.value = timer * 10

func _process(delta: float) -> void:
	charge(delta)

func primary():
	if has_ammo:
		set_process(true)
		anim.play("pull_back")

func primary_release():
	if has_ammo:
		for i in range($"../../..".hotbar.size()):
			if $"../../..".hotbar[i] != null:
				if $"../../..".hotbar[i].name == "Rock":
					$"../../..".hotbar[i] = null
					$"../../..".update_slots()
					break
		set_process(false)
		$"../../..".play_woosh()
		anim.play("release")
		if timer < 1.4:
			launchProj(timer * 1.6)
		else:
			hitscan()
		$CanvasLayer/TextureProgressBar.value = 0
		timer = 0
		check_for_ammo()
