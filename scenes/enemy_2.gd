extends CharacterBody3D

enum States { IDLE, PATROL, ATTACK }
var state := States.IDLE

var target: CharacterBody3D = null
var health: int = 3
var patrol_target: Vector3

@export_range(0, 100, 1) var SPEED: int = 3.5
@export_range(0.0, 10.0, 0.1) var Idle_Time: float = 2.0

@onready var M_Body = $Visuals/Sketchfab_Scene
@onready var audio = $AudioStreamPlayer3D
@export var Patrol_Start: Vector3
@export var min_distance_to_other_enemies: float = 1.5
@export var separation_speed: float = 3.0
@export var Patrol_End: Vector3

var current_patrol_point := 0
var idle_timer: float = 0.0

func _ready() -> void:
	# Если не заданы точки патруля — используем текущую позицию как старт
	if Patrol_Start == Vector3.ZERO:
		Patrol_Start = global_position
	if Patrol_End == Vector3.ZERO:
		Patrol_End = global_position + Vector3(10, 0, 0)
	
	patrol_target = Patrol_Start
	change_state(States.IDLE)


func _physics_process(delta: float) -> void:
	match state:
		States.IDLE:
			idle_state(delta)
		States.PATROL:
			patrol_state(delta)
		States.ATTACK:
			attack_state(delta)
	
	# Гравитация
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# === ИСПРАВЛЕННЫЙ ПОВОРОТ ===
	if velocity.length() > 0.5:
		var target_angle = atan2(velocity.x, velocity.z)
		M_Body.rotation.y = lerp_angle(M_Body.rotation.y, target_angle, delta * 10.0)
	
	move_and_slide()

func take_damage(amount: int) -> void:
	health -= amount
	
	if health <= 0:
		die()

func die() -> void:
	GameManager.add_bs_kill()
	$CollisionShape3D.disabled = true # Отключаем физическое тел
	queue_free()
	
	
func change_state(new_state: States) -> void:
	state = new_state
	
	# Здесь можно запускать разные анимации при смене состояния
	match state:
		States.IDLE:
			# M_Anim.play("Idle")
			pass
		States.PATROL:
			pass
		States.ATTACK:
			pass


# ====================== СОСТОЯНИЯ ======================

func idle_state(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, SPEED * 4)
	velocity.z = move_toward(velocity.z, 0, SPEED * 4)
	
	idle_timer -= delta
	if idle_timer <= 0:
		change_state(States.PATROL)


func patrol_state(delta: float) -> void:
	var distance_to_target = global_position.distance_to(patrol_target)
	
	if distance_to_target < 1.2:
		# Достигли точки — переключаем на следующую
		if current_patrol_point == 0:
			patrol_target = Patrol_End
			current_patrol_point = 1
		else:
			patrol_target = Patrol_Start
			current_patrol_point = 0
		
		# Короткая пауза перед сменой направления
		change_state(States.IDLE)
		idle_timer = 0.8
		return
	
	var direction = (patrol_target - global_position).normalized()
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED


func attack_state(delta: float) -> void:
	if not target or not is_instance_valid(target):
		change_state(States.IDLE)
		return
	
	var distance = global_position.distance_to(target.global_position)
	
	if distance > 1.5:  # дистанция преследования
		var direction = (target.global_position - global_position).normalized()
		velocity.x = direction.x * SPEED * 1.3   # чуть быстрее при погоне
		velocity.z = direction.z * SPEED * 1.3
	else:
		# Достаточно близко — можно добавить атаку
		velocity.x = move_toward(velocity.x, 0, SPEED * 3)
		velocity.z = move_toward(velocity.z, 0, SPEED * 3)
		# Здесь можно запускать анимацию атаки или наносить урон


# ====================== СИГНАЛЫ ======================

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		target = body
		change_state(States.ATTACK)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player") and target == body:
		target = null
		change_state(States.IDLE)


func _on_hit_box_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		# Пример: отбрасывание игрока
		if body.has_method("take_damage") or "velocity" in body:
			body.velocity.y = 8
		self.queue_free()  # враг умирает при касании (можно изменить)


func _on_player_2_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		change_state(States.ATTACK)
