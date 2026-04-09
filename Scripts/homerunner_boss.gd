extends CharacterBody3D

var player 

@export var speed = 3.5
@export var hp = 20.0
@export var dmg = 20

@export var dropChance = 2
@export var minCash = 15
@export var maxCash = 67

var dropped_item = preload("res://Scenes/dropped_item.tscn")
var dropped_money = preload("res://Scenes/money.tscn")
var dir = Vector2.ZERO
var moving = false
var act = false
var isOnCooldown = false
var isStunned = false
var isDead = false
@onready var anim = $AnimationPlayer
@onready var animtree = $AnimationTree
@export var drop_pool = [{name = "Bottle", icon = preload("res://Sprites/Items/empty_bottle.png"),weight = 1, toolObj = preload("res://Scenes/tools/bottle.tscn")},
{name = "Rock", icon = preload("res://Sprites/Items/rock.png"),weight = 1, toolObj = preload("res://Scenes/tools/rock.tscn")},
{name = "Food scraps", icon = preload("res://Sprites/Items/food_scraps.png"),weight = 1, toolObj = preload("res://Scenes/tools/food_scraps.tscn")},
{name = "Baseball bat", icon = preload("res://Sprites/Items/baseball_bat.png"),weight = 4, toolObj = preload("res://Scenes/tools/baseball_bat.tscn")},
{name = "Pizza", icon = preload("res://Sprites/Items/pizza.png"),weight = 1.5, toolObj = preload("res://Scenes/tools/pizza.tscn")},
{name = "Rock", icon = preload("res://Sprites/Items/rock.png"),weight = 1, toolObj = preload("res://Scenes/tools/rock.tscn")},
{name = "Brick", icon = preload("res://Sprites/Items/brick.png"),weight = 2.5, toolObj = preload("res://Scenes/tools/brick.tscn")}]
@onready var raycast = $ray

func getActivated(pl):
	player = pl
	act = true
	moving = true
	player.set_boss_bar("Homerunner", hp)



func die():
	if isDead == true:
		return
	isDead = true
	get_tree().current_scene.remove_active_enemy(self)
	
	for i in drop_pool:
		print(i)
		if randi_range(1,dropChance) == 1:
			var item = dropped_item.instantiate()
			get_tree().current_scene.add_child(item)
			item.global_position = global_position
			item.get_dropped(i, Vector3(randf_range(-3.0,3.0), 3,randf_range(-3.0,3.0)))
	animtree.active = false
	anim.play("dead")
	var money = dropped_money.instantiate()
	get_tree().current_scene.add_child(money)
	money.global_position = global_position
	money.get_dropped(randi_range(minCash,maxCash)*0.1, Vector3(randf_range(-3.0,3.0), 3,randf_range(-3.0,3.0)))
	act = false
	moving = false
	dir = Vector3.ZERO
	

func take_damage(dmg):
	print(dmg)
	player.set_boss_bar("Homerunner", hp)
	hp -= dmg
	if hp <= 0:
		die()

func get_stunned():
	if isStunned == true:
		return
	animtree.active = false
	anim.play("stun")
	isStunned = true
	act = false
	moving = false
	dir = Vector2.ZERO
	$StunTimer.start()
	await $StunTimer.timeout
	act = true
	moving = true
	animtree.active = true
	await get_tree().create_timer(1).timeout
	isStunned = false

func attack():
	if isOnCooldown == true:
		return
		isOnCooldown = true
	moving = false
	animtree.set("parameters/Punch/request",1)
	$AttackWindup.start()
	await $AttackWindup.timeout
	raycast.target_position.y = player.global_position.y - global_position.y 
	if self.global_position.distance_to(player.global_position) < 2 and not raycast.is_colliding():
		player.take_damage(dmg)
	await get_tree().create_timer(1.2).timeout
	
	moving = true
	$AttackCooldown.start()
	await $AttackCooldown.timeout
	isOnCooldown = false

func _physics_process(delta: float) -> void:
	
	animtree.set("parameters/RunBlend/blend_amount", velocity.length() / speed)
	
	if act == true:
		
		dir = ((Vector2(player.global_position.x,player.global_position.z) - Vector2(global_position.x,global_position.z))*5).normalized()
		if self.global_position.distance_to(player.global_position) < 1.5:
			
			
			attack()
		
		
	

	if moving == true:
		
		if !is_on_floor():
			velocity.y = move_toward(velocity.y, get_gravity().y, 0.8)
			
			
			
		else:
			
			velocity.x = move_toward(velocity.x, dir.x * speed, 3 * delta)
			velocity.z = move_toward(velocity.z, dir.y * speed, 3 * delta)
			global_rotation.y = lerp_angle(global_rotation.y, Vector3.BACK.signed_angle_to(Vector3(velocity.x,0,velocity.z),Vector3.UP), 7 * delta)
		move_and_slide()
	else:
		
		velocity = Vector3.ZERO
		
	





func _on_parry_area_body_entered(body: Node3D) -> void:
	
	if isOnCooldown == true or isStunned == true:
		return
	
	attack()
	
	$CollisionShape3D.disabled = true
	var dmg = 10
	if "dmg" in body:
		dmg = body.dmg
	body.parry(((player.global_position + Vector3(0,0.5,0))-body.global_position).normalized())
	if "dmg" in body:
		body.dmg = dmg * 5
	for child in body.get_children():
		if child.name == "Area3D":
			child.set_collision_mask_value(3,true)
			child.set_collision_mask_value(2,false)
	await get_tree().physics_frame
	$CollisionShape3D.disabled = false


func _on_stun_area_body_entered(body: Node3D) -> void:
	take_damage(0.5)
	get_stunned()
