extends Area3D




func _on_body_entered(body: Node3D) -> void:
	
	var enemies = $"../Enemies".get_children()
	
	for enemy in enemies:
		enemy.getActivated(get_tree().current_scene.get_player())
		get_tree().current_scene.add_active_enemy(enemy)
	
	queue_free()
	
