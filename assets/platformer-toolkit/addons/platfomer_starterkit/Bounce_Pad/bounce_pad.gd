extends Area3D

@export_range(1, 50, 1) var Bounce_height: float ## Bounce height of colliding node upon contact

func _ready() -> void:
	self.body_entered.connect(on_body_entered)

func on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.velocity.y = Bounce_height
	pass
