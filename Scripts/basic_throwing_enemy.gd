extends CharacterBody3D

var player 

@export var dropChance = 5
@export var minCash = 15
@export var maxCash = 67

@export var speed = 3.5
@export var hp = 5.0
var rock = preload("res://Scenes/projectiles/enemy_rock_projectile.tscn")
@onready var rPos = $RockPos
@onready var anim = $AnimationPlayer
@onready var animtree = $AnimationTree
var dropped_item = preload("res://Scenes/dropped_item.tscn")
var dropped_money = preload("res://Scenes/money.tscn")
var isDead = false
@export var drop_pool = [{name = "Bottle", icon = preload("res://Sprites/Items/empty_bottle.png"),weight = 1, toolObj = preload("res://Scenes/tools/bottle.tscn")},
{name = "Rock", icon = preload("res://Sprites/Items/rock.png"),weight = 1, toolObj = preload("res://Scenes/tools/rock.tscn")},
{name = "Food scraps", icon = preload("res://Sprites/Items/food_scraps.png"),weight = 1, toolObj = preload("res://Scenes/tools/food_scraps.tscn")},
{name = "Rock", icon = preload("res://Sprites/Items/rock.png"),weight = 1, toolObj = preload("res://Scenes/tools/rock.tscn")},
{name = "Food scraps", icon = preload("res://Sprites/Items/food_scraps.png"),weight = 1, toolObj = preload("res://Scenes/tools/food_scraps.tscn")},
{name = "Rock", icon = preload("res://Sprites/Items/rock.png"),weight = 1, toolObj = preload("res://Scenes/tools/rock.tscn")},
{name = "Brick", icon = preload("res://Sprites/Items/brick.png"),weight = 2.5, toolObj = preload("res://Scenes/tools/brick.tscn")},
{name = "Molotov", icon = preload("res://Sprites/Items/molotov.png"),weight = 1.5, toolObj = preload("res://Scenes/tools/molotov.tscn")}]


var dir = Vector2.ZERO
var moving = false
var act = false
var isOnCooldown = false

func getActivated(pl):
	player = pl
	act = true
	


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
	money.get_dropped(randi_range(minCash*0.1,maxCash*0.1), Vector3(randf_range(-3.0,3.0), 3,randf_range(-3.0,3.0)))
	act = false
	moving = false
	dir = Vector3.ZERO


func take_damage(dmg):
	
	hp -= dmg
	if hp <= 0:
		die()


func attack():
	if isOnCooldown == true:
		return
	isOnCooldown = true
	animtree.set("parameters/throw/request",1)
	$AttackWindup.start()
	await $AttackWindup.timeout
	var rocck = rock.instantiate()
	get_tree().current_scene.add_child(rocck)
	rocck.global_position = rPos.global_position
	rocck.get_thrown(((player.global_position - global_position).normalized() * 13) + Vector3(0,global_position.distance_to(player.global_position) * 0.2,0))
	$AttackCooldown.start(randf_range(0.9,1.5))
	await $AttackCooldown.timeout
	isOnCooldown = false

func _physics_process(delta: float) -> void:
	
	animtree.set("parameters/RunBlend/blend_amount", velocity.length() / 4)
	
	if act:
		var targetpos = (Vector2(global_position.x,global_position.z) - Vector2(player.global_position.x,player.global_position.z)).normalized() * 5 + Vector2(Vector2(player.global_position.x,player.global_position.z))
		dir = (targetpos - Vector2(global_position.x,global_position.z)).normalized()
		if self.global_position.distance_to(player.global_position) < 6 and self.global_position.distance_to(player.global_position) > 4:
			
			moving = false
			
		else:
			moving = true
		
		if self.global_position.distance_to(player.global_position) < 7:
			attack()
	

	if moving:
		
		if !is_on_floor():
			velocity.y = move_toward(velocity.y, get_gravity().y, 0.8)
			
			
			
		else:
			
			velocity.x = move_toward(velocity.x, dir.x * speed, 0.5)
			velocity.z = move_toward(velocity.z, dir.y * speed, 0.5)
			global_rotation.y = lerp_angle(global_rotation.y, Vector3.BACK.signed_angle_to(Vector3(velocity.x,0,velocity.z),Vector3.UP), 10 * delta)
			
	else:
		
		velocity = Vector3.ZERO
	move_and_slide()
