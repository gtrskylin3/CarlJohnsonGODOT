extends CharacterBody3D


@export_range(0, 100, 1) var SPEED: int = 5

@export_range(0, 100, 1) var Jump_Height: int 

var Health := 4.0
var Coin := 0

@onready var Cam = $player_Camera
@onready var M_Body = $Character
@onready var Body = $Character/AnimationPlayer
@onready var Coin_Label : Label = %Coin_Label
@onready var HP_Bar : TextureProgressBar = %Health_Bar

func _process(_delta: float) -> void:
	Coin_Label.text = str(": ", Coin)
	HP_Bar.value = clampf(Health,HP_Bar.min_value,HP_Bar.max_value)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		Body.play("jump",0.5,0.5)

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = Jump_Height
		Body.play("jump",0.5,0.5)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction = (Cam.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		if is_on_floor():
			Body.play("Move",0.5,0.5)
		
		M_Body.rotation.y = lerp_angle(M_Body.rotation.y, atan2(direction.x,direction.z),delta * 10)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		if is_on_floor():
			Body.play("Idle",0.5)
	move_and_slide()

func temp()-> void:
	print(Coin)
