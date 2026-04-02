extends Node3D

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 1.0
@export var max_enemies: int = 10
@export var spawn_radius: float = 8.0

@onready var spawn_timer: Timer = $SpawnTimer

var current_enemies: int = 0
var player: CharacterBody3D = null

func _ready() -> void:
	if not enemy_scene:
		return
	
	# === НАСТРОЙКА ТАЙМЕРА (самый надёжный способ) ===
	if spawn_timer == null:
		spawn_timer = Timer.new()
		spawn_timer.name = "SpawnTimer"
		add_child(spawn_timer)
	
	spawn_timer.wait_time = spawn_interval
	spawn_timer.one_shot = false
	spawn_timer.autostart = true
	
	# Подключаем сигнал БЕЗОПАСНО
	if not spawn_timer.timeout.is_connected(_on_spawn_timer_timeout):
		spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	
	
	# Игрок
	player = get_tree().get_first_node_in_group("player")


func _on_spawn_timer_timeout() -> void:
	
	if max_enemies > 0 and current_enemies >= max_enemies:
		return
	
	spawn_enemy()

@export var min_distance_to_other_enemies: float = 1.5
@export var separation_speed: float = 3.0

func spawn_enemy() -> void:
	
	var enemy = enemy_scene.instantiate()
	if not enemy:
		return
	
	# Случайная позиция
	var offset = Vector3(
		randf_range(-spawn_radius, spawn_radius),
		0.0,
		randf_range(-spawn_radius, spawn_radius)
	)
	enemy.global_position = global_position + offset
	
	
	# Добавляем в сцену (лучше добавлять в current_scene)
	get_tree().current_scene.add_child(enemy)
	# Альтернатива: get_parent().add_child(enemy)
	
	current_enemies += 1
	
	# Передаём игрока врагу
	if player:
		if enemy.has_method("set_target"):
			enemy.set_target(player)
		elif "Target" in enemy:
			enemy.Target = player
	
	# Подключаем смерть
	enemy.tree_exiting.connect(_on_enemy_died.bind(enemy))


func _on_enemy_died(_enemy: Node) -> void:
	current_enemies = max(0, current_enemies - 1)
