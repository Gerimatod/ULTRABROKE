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


func _on_move_button_pressed() -> void:
	$"../../..".move_item(item, self)
