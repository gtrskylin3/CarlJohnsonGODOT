extends Area3D

@onready var audio = $AudioStreamPlayer
@onready var label: Label = $CanvasLayer/Label
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.visible = false
	pass # Replace with function body.


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		print(GameManager.kills)
		if GameManager.kills < 20:
			label.visible = true
			await get_tree().create_timer(3).timeout
			label.visible = false
		else:
			audio.play()
			await get_tree().create_timer(3).timeout
			get_tree().change_scene_to_file("res://scenes/end_text.tscn")
