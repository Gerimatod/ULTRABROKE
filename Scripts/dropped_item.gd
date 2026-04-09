extends Area3D

var int_text = "Pick up "
@export var itemInfo = {name = "item", weight = 1.0, icon = preload("res://Sprites/Items/placeholder.png")}
var isfalling = false
var velocity = Vector3.ZERO
var grav = 10

func get_dropped(item : Dictionary, vel):
	itemInfo = item
	velocity = vel
	isfalling = true
	if item.has("icon"):
		$Texture.texture = item.icon

func get_interact_text():
	return int_text + itemInfo.name

func interact(pl):
	var x = pl.pick_up_item(itemInfo)
	if x == true:
		queue_free()

func _physics_process(delta: float) -> void:
	if isfalling == false:
		set_physics_process(false)
		return
	
	velocity.y -= grav * delta
	if get_overlapping_bodies().size() > 0:
		if $RayCast3D.is_colliding():
			global_position.y += 0.5 - (global_position.distance_to($RayCast3D.get_collision_point()))
			isfalling = false
			set_physics_process(false)
		
		global_position.y += velocity.y * delta
		
	else:
		global_position += velocity * delta
func _ready() -> void:
	if itemInfo:
		$Texture.texture = itemInfo.icon
