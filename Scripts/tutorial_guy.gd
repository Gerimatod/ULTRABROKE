extends CharacterBody3D

@export var dialog = ""

func _on_talk_area_body_entered(body: Node3D) -> void:
	$Dialog.text = dialog


func _on_talk_area_body_exited(body: Node3D) -> void:
	$Dialog.text = ""
