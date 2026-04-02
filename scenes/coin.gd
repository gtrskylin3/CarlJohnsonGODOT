extends Area3D

@export var rotation_speed: float = 2.0
@export var coin_value: int = 1

func _process(delta: float) -> void:
	# Красивое вращение
	rotate_y(rotation_speed * delta)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		# Добавляем монету в общий счет через наш менеджер
		if GameManager.has_method("add_coin"):
			GameManager.add_coin(coin_value)
		
		# Эффект удаления
		queue_free()
