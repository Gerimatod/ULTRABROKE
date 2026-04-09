extends CharacterBody3D



func take_damage(dmg):
	$Label3D.text = "-" + str(dmg)
	
	await get_tree().create_timer(1).timeout
	
	$Label3D.text = ""
