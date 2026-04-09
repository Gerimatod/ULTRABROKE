extends ColorRect

var item = null

func set_info(info:Dictionary):
	item = info
	if info.has("name"):
		$NameLabel.text = info.name
	if info.has("weight"):
		$WeightLabel.text = "Weight: " + str(info.weight)
	if info.has("icon"):
		$TextureRect.texture = info.icon



func _on_equip_button_pressed() -> void:
	$"../../..".equip_item(item, self)


func _on_drop_button_pressed() -> void:
	$"../../..".drop_item(item, self)
