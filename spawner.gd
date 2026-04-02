extends Node3D

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 1.0
@export var max_enemies: int = 10
@export var spawn_radius: float = 8.0

@onready var spawn_timer: Timer = $SpawnTimer

var current_enemies: int = 0
var player: CharacterBody3D = null

func _ready() -> void:
	print("=== SPAWNER STARTED at position ", global_position, " ===")
	
	if not enemy_scene:
		push_error("ERROR: Enemy Scene не назначена в инспекторе!")
		return
	print("OK: Enemy scene загружена: ", enemy_scene.resource_path)
	
	# === НАСТРОЙКА ТАЙМЕРА (самый надёжный способ) ===
	if spawn_timer == null:
		print("INFO: SpawnTimer не найден, создаём новый...")
		spawn_timer = Timer.new()
		spawn_timer.name = "SpawnTimer"
		add_child(spawn_timer)
	
	spawn_timer.wait_time = spawn_interval
	spawn_timer.one_shot = false
	spawn_timer.autostart = true
	
	# Подключаем сигнал БЕЗОПАСНО
	if not spawn_timer.timeout.is_connected(_on_spawn_timer_timeout):
		spawn_timer.timeout.connect(_on_spawn_timer_timeout)
		print("OK: Сигнал timeout подключён")
	else:
		print("OK: Сигнал timeout уже подключён")
	
	print("OK: Таймер запущен с интервалом ", spawn_interval, " сек\n")
	
	# Игрок
	player = get_tree().get_first_node_in_group("player")
	if player:
		print("OK: Игрок найден")
	else:
		print("WARNING: Игрок не найден в группе 'player'")


func _on_spawn_timer_timeout() -> void:
	print("→ Timer triggered! Пытаемся заспавнить врага...")
	
	if max_enemies > 0 and current_enemies >= max_enemies:
		print("   LIMIT: Максимум врагов достигнут (", current_enemies, "/", max_enemies, ")")
		return
	
	spawn_enemy()


func spawn_enemy() -> void:
	print("   → spawn_enemy() вызвана")
	
	var enemy = enemy_scene.instantiate()
	if not enemy:
		print("   ERROR: Не удалось instantiate врага!")
		return
	
	# Случайная позиция
	var offset = Vector3(
		randf_range(-spawn_radius, spawn_radius),
		0.0,
		randf_range(-spawn_radius, spawn_radius)
	)
	enemy.global_position = global_position + offset
	
	print("   INFO: Враг создан на позиции ", enemy.global_position)
	
	# Добавляем в сцену (лучше добавлять в current_scene)
	get_tree().current_scene.add_child(enemy)
	# Альтернатива: get_parent().add_child(enemy)
	
	current_enemies += 1
	print("   OK: Враг добавлен! Текущее количество: ", current_enemies)
	
	# Передаём игрока врагу
	if player:
		if enemy.has_method("set_target"):
			enemy.set_target(player)
			print("   OK: set_target() вызван")
		elif "Target" in enemy:
			enemy.Target = player
			print("   OK: Target присвоен")
		else:
			print("   WARNING: У врага нет set_target() и переменной Target")
	
	# Подключаем смерть
	enemy.tree_exiting.connect(_on_enemy_died.bind(enemy))
	print("   OK: Сигнал смерти подключён\n")


func _on_enemy_died(_enemy: Node) -> void:
	current_enemies = max(0, current_enemies - 1)
	print("   ENEMY DIED → Осталось врагов: ", current_enemies)
