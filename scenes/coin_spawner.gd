extends Node3D

@export var coin_scene: PackedScene # Перетащите сюда Coin.tscn в инспекторе
@export var spawn_count: int = 10    # Сколько монет спавнить
@export var spawn_area_size: Vector3 = Vector3(20, 0, 20) # Размер зоны спавна

func _ready() -> void:
	spawn_coins()

func spawn_coins() -> void:
	if not coin_scene:
		print("Ошибка: Сцена монеты не назначена в спавнере!")
		return

	for i in range(spawn_count):
		var coin = coin_scene.instantiate()
		add_child(coin)
		
		# Генерируем случайную позицию в пределах заданной зоны
		var random_pos = Vector3(
			randf_range(-spawn_area_size.x / 2, spawn_area_size.x / 2),
			0.5, # Высота над землей
			randf_range(-spawn_area_size.z / 2, spawn_area_size.z / 2)
		)
		
		coin.position = random_pos
