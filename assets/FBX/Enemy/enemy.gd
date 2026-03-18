extends CharacterBody3D

enum States {IDLE,PATROL,ATTACK}
var state := States.IDLE

var Patrolling : bool = false
var Patrol_S = true
var Target : CharacterBody3D

@export_range(0, 100, 1) var SPEED: int = 3
@export_range(0.0, 10.0, 1) var Idle_Timer : float = 2.0
@onready var M_Body = $Character
@onready var M_Anim = $Character/AnimationPlayer

@export var Patrol_Start: Vector3
@export var Patrol_End: Vector3
@onready var Start_Pos = self.global_position

func _physics_process(delta: float) -> void:
	match state:
		States.IDLE:
			idle()
		States.PATROL:
			if Patrolling == false:
				if Start_Pos.distance_to(self.global_position) > 1:
					var direction = (Start_Pos - global_position).normalized()
					velocity.x = direction.x * SPEED
					velocity.z = direction.z * SPEED
				else:
					Patrol()
		States.ATTACK:
			Attack()
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	M_Body.rotation.y = lerp_angle(M_Body.rotation.y, atan2(velocity.x,velocity.z),delta * 10)
	move_and_slide()

func changee_state(new_state) -> void:
	state = new_state

func idle() -> void:
	M_Anim.play("Idle")
	velocity.x = move_toward(velocity.x, 0, SPEED)
	velocity.z = move_toward(velocity.z, 0, SPEED)
	
	await get_tree().create_timer(Idle_Timer).timeout
	changee_state(States.PATROL)

func Patrol() -> void:
	Patrolling = true
	pass

func Attack() ->void:
	M_Anim.play("Move")
	if Target.global_position.distance_to(self.global_position) > 1:
		var direction = (Target.global_position - global_position).normalized()
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED

func _on_detection_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		Target = body
		changee_state(States.ATTACK)

func _on_detection_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		changee_state(States.IDLE)

func _on_hit_box_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.velocity.y = 5
		self.queue_free()
