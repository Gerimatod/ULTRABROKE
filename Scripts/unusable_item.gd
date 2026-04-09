extends tool

func on_equip(iteminfo : Dictionary):
	if iteminfo.has("icon"):
		$Sprite3D.texture = iteminfo.icon
