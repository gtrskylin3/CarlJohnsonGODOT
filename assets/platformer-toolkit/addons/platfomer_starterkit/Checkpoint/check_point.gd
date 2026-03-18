extends Area3D

@export_enum("Start","Checkpoint","End") var Checkpoint_type : int ## Determines the ceheckpoint varient. Only one "Start" and "End" checkpoint should exist in a scene
@export var Checkpoint_number : int

@onready var database = $"/root/SaveSystem"
## Called when the node enters the scene tree for the first time.

@export_group("Start State", "Start")
@export var Start_Current_level : int ## Value determines the current level which is then updated on the save script. Ignore if state checkpoint type not start
@export var Start_Player_Scene: PackedScene ## Variable should point to the players scene. Ignore if state checkpoint type not start

@export_group("End State", "End")
@export var End_Level: PackedScene ## New level changing to upon contact. Ignore if state checkpoint type not end

func _init() -> void:
	## Adds node to group upon instantiation in scene
	self.add_to_group("Checkpoint")

func _ready() -> void:
	## Calls the function to determine player spawn position if nodeis a start checkpoint type
	if Checkpoint_type == 0:
		#await get_tree().process_frame
		Spawn(Data())
	if Checkpoint_type == 2:
		level_validation()
	
	self.body_entered.connect(on_body_entered)

func Spawn(a):
	var instance = Start_Player_Scene.instantiate()
	get_tree().current_scene.add_child.call_deferred(instance)
	instance.global_position = self.global_position
	Checkpoint_Verify(global_position)

func on_body_entered(body: Node3D) -> void:
	## Function saves the players new position upon contact with Checkpoint node
	if body.is_in_group("player"):
		if Checkpoint_type == 1:
			## Change scene if node is of Checkpoint type
			database.set_setting("PLAYER POSITION","X",body.global_position.x)
			database.set_setting("PLAYER POSITION","Y",body.global_position.y)
			database.set_setting("PLAYER POSITION","Z",body.global_position.z)
			Checkpoint_Verify(global_position)
	
		if Checkpoint_type == 2:
			## Change scene if node is of End type
			get_tree().call_deferred("change_scene_to_packed", End_Level)
		database.SaveValues()

func Data():
	## Function retrieves the player position from save script and assigns to a variable (temp_location)
	## The created variable is returned as the players new position if not == 0 else returns the start node position 
	var temp_location = Vector3(
	database.get_setting("PLAYER POSITION","X"),
	database.get_setting("PLAYER POSITION","Y"),
	database.get_setting("PLAYER POSITION","Z"),
	)
	
	if temp_location != Vector3.ZERO:
		return temp_location
	return global_position

func Checkpoint_Verify(temp_pos) -> void:
	## Line 49-51 determines the last checkpoint by distance and assigns it to a vaiavle called (pos_checkpoint_number)
	## Line 54-56 determines the next checkpoints and delete previous ones to disable updating the wrong checkpoint
	var A_checkpoints = get_tree().get_nodes_in_group("Checkpoint")
	for i in A_checkpoints:
		if i.global_position.distance_to(temp_pos) < 2:
			var pos_checkpoint_number = i.Checkpoint_number
			
			for n in get_tree().get_nodes_in_group("Checkpoint"):
				if n.Checkpoint_number < pos_checkpoint_number :
					n.queue_free()

func level_validation() -> void:
	## Function confirms if currently saved level lower and then updates it scene level
	if database.get_setting("GAME_LEVELS","GAME_UNLOCKED_LEVEL") <= Start_Current_level:
		database.set_setting("GAME_LEVELS","GAME_UNLOCKED_LEVEL",Start_Current_level)
		database.SaveValues()
