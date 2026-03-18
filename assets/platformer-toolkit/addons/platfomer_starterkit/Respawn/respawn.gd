extends Area3D

@export var Auto_reload : bool = true

var Active : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.body_entered.connect(on_body_entered)

func on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		if Auto_reload == true:
			Active = true
			call_deferred("_reload_scene")
		else:
			Active = true

func _reload_scene() -> void:
	get_tree().reload_current_scene()
