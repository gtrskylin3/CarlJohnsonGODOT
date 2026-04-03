extends CharacterBody3D

enum States { IDLE, PATROL, ATTACK }
var state := States.IDLE

var target: CharacterBody3D = null
var health: int = 3
var patrol_target: Vector3
var choices = [1, 2, 3, 4, 5, 6]

@export_range(0, 100, 1) var SPEED: int = 3.5
@export_range(0.0, 10.0, 0.1) var Idle_Time: float = 2.0

@onready var M_Body = $Visuals/zombie
@onready var audio = $AudioStreamPlayer3D
@onready var M_Anim = $Visuals/zombie/AnimationPlayer
@export var JUMP_VELOCITY: float = 5
@export var Patrol_Start: Vector3
@export var min_distance_to_other_enemies: float = 1.5
@export var separation_speed: float = 3.0
@export var Patrol_End: Vector3

var current_patrol_point := 0
var idle_timer: float = 0.0
var is_roaring: bool

func _ready() -> void:
	# Если не заданы точки патруля — используем текущую позицию как старт
	if Patrol_Start == Vector3.ZERO:
		Patrol_Start = global_position
	if Patrol_End == Vector3.ZERO:
		Patrol_End = global_position + Vector3(10, 0, 0)
	
	patrol_target = Patrol_Start
	change_state(States.IDLE)


func _physics_process(delta: float) -> void:
	if is_roaring:
		change_state(States.ATTACK)
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
		target_angle += PI          # ← Вот эта строчка решает проблему "спиной вперёд"
		M_Body.rotation.y = lerp_angle(M_Body.rotation.y, target_angle, delta * 10.0)
	
	move_and_slide()

func take_damage(amount: int) -> void:
	health -= amount
	
	if health <= 0:
		die()

func die() -> void:
	GameManager.add_kill()
	$CollisionShape3D.set_deferred("disabled", true)
	
	# 1. Получаем направление взгляда игрока
	# Предположим, переменная 'target' — это игрок (из Area3D)
	# Если target пуст, берем игрока из группы
	var player = target
	if not player:
		player = get_tree().get_first_node_in_group("player")
	
	var knockback_distance = 15.0 # Дистанция полета
	var knockback_time = 0.8     # Длительность
	
	if player:
		# Получаем вектор «вперед» игрока (куда он смотрит)
		var push_direction = player.global_transform.basis.z.normalized()
		
		# Вычисляем финальную точку (текущая позиция + направление * дистанция)
		var target_pos = global_position + (push_direction * knockback_distance)
		
		# Чтобы зомби не улетал под землю или в небо, фиксируем Y
		target_pos.y = global_position.y 

		var tween = create_tween()
		tween.tween_property(self, "global_position", target_pos, knockback_time)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# 2. Анимация и удаление
	M_Anim.play("Smash")
	var anim_length = M_Anim.get_animation("Smash").length
	await get_tree().create_timer(anim_length - 0.2).timeout
	queue_free()
	
	
func change_state(new_state: States) -> void:
	state = new_state
	
	# Здесь можно запускать разные анимации при смене состояния
	match state:
		States.IDLE:
			# M_Anim.play("Idle")
			pass
		States.PATROL:
			var anim = M_Anim.get_animation("Walk")
			anim.loop_mode = Animation.LOOP_LINEAR # Включает цикл
			M_Anim.play("Walk")
		States.ATTACK:
			var anim = M_Anim.get_animation("Walk")
			anim.loop_mode = Animation.LOOP_LINEAR # Включает цикл
			M_Anim.play("Walk")


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
	
	# Движение к цели
	if distance > 1.5:
		var direction = (target.global_position - global_position).normalized()
		velocity.x = direction.x * SPEED * 1.3
		velocity.z = direction.z * SPEED * 1.3
		
		# === ЛОГИКА ПРЫЖКА ===
		if is_on_floor():
			# Условие А: Игрок значительно выше врага
			var height_diff = target.global_position.y - global_position.y
			
			# Условие Б: Враг во что-то врезался (стенка или ступенька)
			var is_blocked = is_on_wall() 
			
			if (height_diff > 1.0 or is_blocked) and (distance >= 5 and distance <= 30):
				velocity.y = JUMP_VELOCITY
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 3)
		velocity.z = move_toward(velocity.z, 0, SPEED * 3)

# ====================== СИГНАЛЫ ======================

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		target = body
		change_state(States.ATTACK)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player") and target == body:
		target = null
		change_state(States.IDLE)

func _on_player_2_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		if choices.pick_random() in [1,2,3]:
			M_Anim.play("Roar", 0.1, 1.5)
			audio.play()
			if body.has_method("take_damage"):
				body.take_damage(5)
			await get_tree().create_timer(M_Anim.get_animation("Roar").length-4).timeout
			is_roaring = true
		change_state(States.ATTACK)
