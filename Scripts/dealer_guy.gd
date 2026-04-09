extends Node3D

var hasHandedOut = false

var drugs = [{item = {name = "Asteroids", weight = 0.2, icon = preload("res://Sprites/Items/asteroids.png")}, cost = 3},
{item = {name = "Cracked chocolate", weight = 0.3, icon = preload("res://Sprites/Items/chocolate_crack.png")}, cost = 5},
{item = {name = "Coffee bean", weight = 0.1, icon = preload("res://Sprites/Items/speed_ball.png")}, cost = 2},
{item = {name = "Cough drop", weight = 0.1, icon = preload("res://Sprites/Items/bluupill.png")}, cost = 3}]

func _on_area_3d_body_entered(body: Node3D) -> void:
	if hasHandedOut == false:
		hasHandedOut = true
		var drug_selection = []
		for i in range(4):
			while true:
				var drug = drugs.pick_random()
				if !drug_selection.has(drug):
					drug_selection.append(drug)
					break
		
		await get_tree().physics_frame
		
		
		
		$Drug1.visible = true
		$Drug1/Texture.texture = drug_selection[0].item.icon
		$Drug1/Drug1_buy_area.item = drug_selection[0].item
		$Drug1/Drug1_buy_area.cost = drug_selection[0].cost
		$Drug1/Drug1_buy_area.int_text = "Buy " + drug_selection[0].item.name + " - $" + str(drug_selection[0].cost)
		$Drug2.visible = true
		$Drug2/Texture.texture = drug_selection[1].item.icon
		$Drug2/Drug2_buy_area.item = drug_selection[1].item
		$Drug2/Drug2_buy_area.cost = drug_selection[1].cost
		$Drug2/Drug2_buy_area.int_text = "Buy " + drug_selection[1].item.name + " - $" + str(drug_selection[1].cost)
		$Drug3.visible = true
		$Drug3/Texture.texture = drug_selection[2].item.icon
		$Drug3/Drug3_buy_area.item = drug_selection[2].item
		$Drug3/Drug3_buy_area.cost = drug_selection[2].cost
		$Drug3/Drug3_buy_area.int_text = "Buy " + drug_selection[2].item.name + " - $" + str(drug_selection[2].cost)
		$Dialog.text = "Hey kid. Wanna have something\nto take the edge off?"
		$AnimationPlayer.play("handout")
		await get_tree().create_timer(3).timeout
		$Dialog.text = ""





func _on_drug_1_buy_area_bought() -> void:
	
	$Drug1/Texture.queue_free()
	$Drug1/Drug1_buy_area.queue_free()


func _on_drug_2_buy_area_bought() -> void:
	$Drug2/Texture.queue_free()
	$Drug2/Drug2_buy_area.queue_free()
	
	
func _on_drug_3_buy_area_bought() -> void:
	$Drug3/Texture.queue_free()
	$Drug3/Drug3_buy_area.queue_free()
	
