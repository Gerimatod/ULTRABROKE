extends CharacterBody3D

var hp = 100
var max_hp = 100
var hunger = 0
var speed = 5.0
var slidespeed = 15.0
var mdir:Vector2 
var jumpForce = 4
@onready var cam = $Camera
@onready var anim = $Camera/AnimationPlayer
@onready var toolholder = $Camera/ToolHolder
@onready var punchRayCast = $Camera/PunchCast
@onready var interactCast = $Camera/InteractCast
@onready var punchCoolDown = $punchCoolDown
@onready var parryFlash = $Camera/UI/ParryFlash
@onready var parryFreezeframe = $parryFreezeframe
@onready var collider = $CollisionShape3D
@onready var slideParticle = $ParticlePivot/Particles
@onready var slideParticlePivot = $ParticlePivot
@onready var inventoryList = $Camera/UI/Inventory/CoolItemList
@onready var interactionTooltip = $Camera/UI/Crosshair/InteractionTooltip
@onready var hotbar_pointer = $Camera/UI/Hotbar/Slot1/pointer
@onready var money_ui = $Camera/UI/Money/Label
@onready var parry_sound = $ParrySound
@onready var box_ui = $Camera/UI/BoxUI
@onready var box_ui_list = $Camera/UI/BoxUI/Box
@onready var box_ui_inv = $Camera/UI/BoxUI/Inventory
@export_range(5, 15) var sensitivity = 4.0
@export var knockback = 10.0
@export var damage = 1.0
var IsMouseCaptured = false
var zoom = 7.0
var canjump = true
var canpunch = true
var canMove = true
var inventory = []
var money = 0.0
var hotbar = [null,null,null,null]
var currentslot = 0
var maxweight = 15.0

var isBoxUiOpen = false
var isInvOpen = false
var isSliding = false
var slideDir:Vector2
var slideVel = 0
var placeholdertex = preload("res://Sprites/Items/placeholder.png")
var droppedItem = preload("res://Scenes/dropped_item.tscn")
var emptyslottex = preload("res://Sprites/UI/weapon_slot.png")
var utilslottex = preload("res://Sprites/UI/util_slot.png")
var unusableitem = preload("res://Scenes/tools/unusable_item.tscn")
var box = null
@onready var calm_music = $music_calm
@onready var combat_music = $music_combat
@onready var uiSlots = [$Camera/UI/Inventory/Slot1/Texture,$Camera/UI/Inventory/Slot2/Texture,$Camera/UI/Inventory/Slot3/Texture,$Camera/UI/Inventory/UtilSlot/Texture]
@onready var uiHotbar = [$Camera/UI/Hotbar/Slot1/Texture,$Camera/UI/Hotbar/Slot2/Texture,$Camera/UI/Hotbar/Slot3/Texture,$Camera/UI/Hotbar/UtilSlot/Texture]

func slide(val:bool):
	if val == true:
		$slide_sound.play()
		collider.shape.height = 1
		cam.position.y = 0.2
		if mdir == Vector2.ZERO:
			slideDir = Vector2(0,-1).rotated(-cam.rotation.y)
		else:
			slideDir = mdir
		isSliding = true
		slideVel = slidespeed
		slideParticlePivot.rotation_degrees.y = rad_to_deg(-slideDir.angle()) - 90
		slideParticle.emitting = true
	else :
		$slide_sound.stop()
		cam.position.y = 0.5
		collider.shape.height = 2
		isSliding = false
		slideParticle.emitting = false

func set_music(is_calm):
	if is_calm == true:
		calm_music.volume_db = -3
		combat_music.volume_db = -80
	else:
		
		calm_music.volume_db = -80
		combat_music.volume_db = 0

func start_music():
	calm_music.volume_db = -3
	combat_music.volume_db = -80
	calm_music.play()
	combat_music.play()

func stop_music():
	calm_music.playing = false
	combat_music.playing = false

func set_boss_bar(name, hp):
	$Camera/UI/Bossbar/bar/name.text = name
	$Camera/UI/Bossbar/bar.value = hp
	$Camera/UI/Bossbar.visible = true
	if hp <= 0:
		await get_tree().create_timer(1).timeout
		$Camera/UI/Bossbar.visible = false

func open_box_ui(Box):
	box_ui.visible = true
	isBoxUiOpen = true
	box = Box
	
	capture_mouse(false)
	
	update_box_ui()
	
	

func update_box_ui():
	box_ui_list.clear()
	box_ui_inv.clear()
	$Camera/UI/BoxUI/BoxWeightLabel2.text = "Carrying capacity: " + str(box.weight) + "/" + str(box.box_max_weight)
	for i in range(box.box_contents.size()):
		box_ui_list.add_item(box.box_contents[i])
	for i in range(inventory.size()):
		box_ui_inv.add_item(inventory[i])

func close_box_ui():
	isBoxUiOpen = false
	box_ui.visible = false
	capture_mouse(true)

func move_item(into_box,item):
	if into_box == true:
		
		var index = inventory.find(item)
		if index == -1:
			print("Item doesnt exist :(")
			return false
		var success = box.add_to_box(item)
		if success == true:
			inventory.remove_at(index)
			update_inventory()
			update_box_ui()
			return true
		else :
			return false
	else:
		var index = box.box_contents.find(item)
		if index == -1:
			print("Item doesnt exist :(")
			return false
		var success = pick_up_item_into_inventory(item)
		if success == true:
			box.box_contents.remove_at(index)
			box.update_weight()
			update_inventory()
			update_box_ui()
			return true
		else :
			return false

func pick_up_money(amount):
	money += amount
	money_ui.text = "$" + str(money)

func purchase_attempt(price):
	if price > money:
		return false
	else:
		money -= price
		pick_up_money(0)
		return true

func set_weight_label():
	await get_tree().physics_frame
	var weight = 0
	for i in range(inventory.size()):
		
		weight += inventory[i].weight
	
	$Camera/UI/Inventory/WeightLabel.text = "Carrying capacity: " + str(weight) + "/" + str(maxweight)
	$Camera/UI/BoxUI/InvWeightLabel.text = "Carrying capacity: " + str(weight) + "/" + str(maxweight)

func update_inventory():
	await get_tree().physics_frame
	inventoryList.clear()
	var weight = 0.0
	
	
	for i in range(inventory.size()):
		inventoryList.add_item(inventory[i])
		weight += inventory[i].weight
	
	
	set_weight_label()

func add_item_to_inv(item:Dictionary):
	inventoryList.add_item(item)
	

func pick_up_item(item : Dictionary):
	var weight = 0.0
	
	for i in range(inventory.size()):
		weight += inventory[i].weight
	
	if weight + item.weight > maxweight:
		print("Not enough space in backback!")
		return false
	inventory.append(item)
	set_weight_label()
	add_item_to_inv(item)
	equip_item(item)
	return true

func pick_up_item_into_inventory(item : Dictionary):
	var weight = 0.0
	
	for i in range(inventory.size()):
		weight += inventory[i].weight
	
	if weight + item.weight > maxweight:
		print("Not enough space in backback!")
		return false
	inventory.append(item)
	set_weight_label()
	add_item_to_inv(item)
	
	return true

func get_cam():
	return cam

func drop_item(item:Dictionary):
	var index = inventory.find(item)
	if index == -1:
		print("Item doesnt exist :(")
		return false
	var itemobj = droppedItem.instantiate()
	$"..".add_child(itemobj)
	itemobj.global_position = cam.global_position
	itemobj.get_dropped(inventory[index], -cam.global_transform.basis.z * 2)
	inventory.remove_at(index)
	update_inventory()
	return true

func update_slots():
	for i in range(hotbar.size()):
		var slot = hotbar[i]
		if slot != null:
			if slot.has("icon"):
				uiSlots[i].texture = slot.icon
				uiHotbar[i].texture = slot.icon
			else:
					uiSlots[i].texture = placeholdertex
					uiHotbar[i].texture = placeholdertex
		else:
			if i == 3:
				uiSlots[i].texture = utilslottex
				uiHotbar[i].texture = utilslottex
			else:
				uiSlots[i].texture = emptyslottex
				uiHotbar[i].texture = emptyslottex
	switch_slots()
	set_weight_label()

func eat(amount):
	hunger += amount
	$Camera/UI/Inventory/hungerbar.value = hunger
	$Camera/UI/Inventory/hungerbar/hungerlabel.text = str(hunger)

func play_night_amibiance():
	$night_sound.play()
	
func stop_night_ambiance():
	$night_sound.stop()

func equip_item(item:Dictionary):
	var index = inventory.find(item)
	if index == -1:
		print("Item doesnt exist :(")
		return false
	elif item.has("itemType"):
		if item.type == "util":
			if hotbar[3] == null:
				hotbar[3] = item
				update_slots()
				inventory.remove_at(index)
				update_inventory()
				set_weight_label()
				return true
	for i in range(hotbar.size()):
		var slot = hotbar[i]
		if i != 3:
			if slot == null:
				hotbar[i] = item
				update_slots()
				inventory.remove_at(index)
				update_inventory()
				set_weight_label()
				return true
		
	update_inventory()
	set_weight_label()
	
	return false

func capture_mouse(val):
	if val == true:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		IsMouseCaptured = true
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		IsMouseCaptured = false

func die():
	if get_tree():
		capture_mouse(false)
		get_tree().call_deferred("change_scene_to_file","res://Scenes/main_menu.tscn")

func take_damage(dmg):
	hp = clamp(hp - dmg, -1, max_hp)
	$Camera/UI/Bars/hpbar.value = hp
	$Camera/UI/Bars/hpbar/hplabel.text = str(floor(hp))
	if hp <= 0:
		die()

func interact():
	if interactCast.is_colliding():
		var obj = interactCast.get_collider()
		obj.interact(self)

func open_inventory():
	if isInvOpen == false:
		isInvOpen = true
		capture_mouse(false)
		$Camera/UI/Inventory.visible = true
	else:
		isInvOpen = false
		capture_mouse(true)
		$Camera/UI/Inventory.visible = false

func switch_slots():
	
	
	
	for x in $Camera/ToolHolder.get_children():
		x.on_unequip()
		x.queue_free()
		

	var slot = hotbar[floor(currentslot/2)]
	
	hotbar_pointer.get_parent().remove_child(hotbar_pointer)
	uiHotbar[floor(currentslot/2)].add_child(hotbar_pointer)
	
	
	if slot != null:
		if slot.has("toolObj"):
			var tObj = slot.toolObj.instantiate()
			$Camera/ToolHolder.add_child(tObj)
			tObj.on_equip(slot)
		else:
			var tObj = unusableitem.instantiate()
			$Camera/ToolHolder.add_child(tObj)
			tObj.on_equip(slot)
			

func wait_for_room_gen():
	$Camera/UI/Loading_screen/Label.text = "Travelling to the alleys..."
	$Camera/UI/Loading_screen/Label/AnimatedSprite2D.play("stopwatch")
	$Camera/UI/Loading_screen.visible = true
	await $"../RoomGeneration".is_done_generating
	$Camera/UI/Loading_screen.visible = false

func go_home():
	$Camera/UI/Loading_screen/Label.text = "Travelling home..."
	$Camera/UI/Loading_screen/Label/AnimatedSprite2D.play("stopwatch")
	cam.environment.background_color = "000203"
	$Camera/UI/Loading_screen.visible = true
	await get_tree().create_timer(1).timeout
	$Camera/UI/Loading_screen.visible = false
	

func sleep():
	if inventory == []:
		sleep_gui()
		return true
	else:
		flash_sleep_label()
		return false

func flash_sleep_label():
	$Camera/UI/SleepLabel.visible = true
	await get_tree().create_timer(1).timeout
	$Camera/UI/SleepLabel.visible = false

func sleep_gui():
	$Camera/UI/Loading_screen/Label.text = "Sleeping..."
	$Camera/UI/Loading_screen/Label/AnimatedSprite2D.play("zzz")
	$Camera/UI/Loading_screen.visible = true
	
	if hunger >= 10:
		hp = 100
		take_damage(0)
	hunger = 0
	cam.environment.background_color = "#5084a1"
	$Camera/UI/Inventory/hungerbar.value = 0
	$Camera/UI/Inventory/hungerbar/hungerlabel.text = "0"
	await get_tree().create_timer(1).timeout
	$Camera/UI/Loading_screen.visible = false
	stop_night_ambiance()
	if money >= 150:
		$Camera/UI/WinScreen.visible = true
		capture_mouse(false)
		$Camera/UI/WinScreen/DayCounter.text = "Finished in " + str($"../Home".days) + " days"

func punch():
	if canpunch == false:
		return
	anim.play("punch")
		
	if punchRayCast.is_colliding():
		var obj = punchRayCast.get_collider()
		if obj != null:
			if obj.get_collision_layer_value(2):
				obj.take_damage(1)
				
			else:
				parry_sound.play(0.2)
				take_damage(7)
				obj.parry(-cam.global_transform.basis.z)
				await get_tree().create_timer(0.06).timeout
				parryFlash.visible = true
				get_tree().paused = true
				await get_tree().create_timer(0.2).timeout
				get_tree().paused = false
				parryFlash.visible = false
				
		
	punchCoolDown.start()
	canpunch = false
	await punchCoolDown.timeout
	canpunch = true

func _input(event: InputEvent) -> void:
	

	
	# V Inputs V
	
	if isInvOpen == true:
		if Input.is_action_just_pressed("inventory"):
			open_inventory()
		return
	if isBoxUiOpen == true:
		if Input.is_action_just_pressed("inventory"):
			close_box_ui()
		return
	if event is InputEventMouseMotion:
		if IsMouseCaptured:
			cam.rotation.y -= event.relative.x * sensitivity * 0.001
			cam.rotation.x = clamp(cam.rotation.x-(event.relative.y * sensitivity * 0.001), -1.5, 1.5)
	elif Input.is_action_just_pressed("punch") and canpunch == true:
		punch()
	elif Input.is_action_just_pressed("primary"):
		if toolholder.get_child_count() == 1:
			toolholder.get_children()[0].primary()
		else:
			punch()
	elif Input.is_action_just_pressed("secondary"):
		if toolholder.get_child_count() == 1:
			toolholder.get_children()[0].secondary()
	elif Input.is_action_just_pressed("debug"):
		$"../Home".end_run()
	elif Input.is_action_just_released("primary"):
		if toolholder.get_child_count() == 1:
			toolholder.get_children()[0].primary_release()
	elif Input.is_action_just_released("secondary"):
		if toolholder.get_child_count() == 1:
			toolholder.get_children()[0].secondary_release()
	elif Input.is_action_just_pressed("inventory"):
		if isBoxUiOpen == false:
			open_inventory()
		else:
			close_box_ui()
	elif Input.is_action_just_pressed("slide"):
		slide(true)
	elif Input.is_action_just_released("slide"):
		slide(false)
	elif Input.is_action_just_pressed("interact"):
		interact()
	elif Input.is_action_just_pressed("scrolldown"):
		currentslot = clamp(currentslot + 1, 0, 6)
		switch_slots()
	elif Input.is_action_just_pressed("scrollup"):
		currentslot = clamp(currentslot - 1, 0, 6)
		switch_slots()
	

func _ready() -> void:
	capture_mouse(true)
	update_inventory()

func _process(delta: float) -> void:
	mdir = Input.get_vector("left", "right", "up", "down")
	mdir = mdir.normalized().rotated(-cam.rotation.y)
	

	# V Interaction thingy V
	
	if interactCast.is_colliding():
		var obj = interactCast.get_collider()
		if obj == null:
			return
		if interactionTooltip.visible == false:
			interactionTooltip.visible = true
		if obj.has_method("get_interact_text"):
			interactionTooltip.text = "E - " + obj.get_interact_text()
		else:
			interactionTooltip.text = "E - Interact"
	else:
		if interactionTooltip.visible == true:
			interactionTooltip.visible = false
	
	

func _physics_process(delta: float) -> void:
	
	if is_on_floor():
		canjump = true 
	else:
		canjump = false
	if canMove == true:
		if isSliding == false:
			if mdir != Vector2(0,0):
				velocity.x = mdir.x * speed
				velocity.z = mdir.y * speed
			
			
			
			else:
				velocity.x = 0
				velocity.z = 0
		else:
			velocity.x = slideDir.x * slideVel
			velocity.z = slideDir.y * slideVel
			slideVel = clampf(slideVel - delta * 2, 0, slidespeed * 2)
			if slideVel < 2:
				slide(false)


	if !is_on_floor():
		velocity.y += get_gravity().y * delta
	
	if Input.is_action_just_pressed("jump"):
		if canjump:
			velocity.y = jumpForce
			
	
	
	
	
	move_and_slide()


func play_woosh():
	$woosh.play()

func _on_slot_1_pressed() -> void:
	if hotbar[0] == null:
		return
	var x = pick_up_item_into_inventory(hotbar[0])
	if x == true:
		hotbar[0] = null
	update_slots()

func _on_slot_2_pressed() -> void:
	if hotbar[1] == null:
		return
	var x = pick_up_item_into_inventory(hotbar[1])
	if x == true:
		hotbar[1] = null
	update_slots()

func _on_slot_3_pressed() -> void:
	if hotbar[2] == null:
		return
	var x = pick_up_item_into_inventory(hotbar[2])
	if x == true:
		hotbar[2] = null
	update_slots()

func _on_util_slot_pressed() -> void:
	if hotbar[3] == null:
		return
	var x = pick_up_item_into_inventory(hotbar[3])
	if x == true:
		hotbar[3] = null
	update_slots()


func _on_replay_button_pressed() -> void:
	get_tree().call_deferred("reload_current_scene")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
