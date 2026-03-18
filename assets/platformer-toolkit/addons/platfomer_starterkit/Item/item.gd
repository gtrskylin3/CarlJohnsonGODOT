extends Area3D

@export_group("Item Details", "Item")
@export_placeholder("Enter item name") var Item_Name: String ## item name should be exactly the same as the variable updating along with case
@export_range(0, 100, 1) var Item_Amount: int ## Item amount for a single node
@export_enum("None","Rotate", "Bounce") var Item_Motion : int ## Item Animaton motion
@export_enum("None","Consumable", "PowerUp") var Item_Type : int ## Item Animaton motion
@export_range(0, 100, 1) var Item_Power_Up_Time: int ## Duration for a power up to last before reverting to default values

@export_group("Rotation settings", "Rotation")
@export var Rotation_Axis: Vector3 ## Node rotation axis. 0 represent no rotation and 1 represents rotation along selected axis 
@export_range(0.1, 5, 0.1) var Rotation_speed: float ## Represnts rotation speed of node during rotation 
@onready var start_rot = self.global_rotation_degrees

@export_group("Bounce settings", "Bounce")
@export var Bounce_axis: Vector3 ## Node bounce axis. 0 represent no movemnt and 1 represents movement along selected axis
@export_range(0.1, 10, 0.1) var Bounce_height: float ## Represnts node bounce height from current global position 
@export_range(0.1, 5, 0.1) var Bounce_speed: float ## Represnts bounce speed of node during bounce 

@onready var start_pos = self.global_position
@onready var tween = get_tree().create_tween()
var temp_val

func _ready() -> void:
	Value_limit()
	self.body_entered.connect(on_body_entered)
	
	if Item_Motion > 0:
		if Item_Motion == 1:
			tween.tween_property(self, "rotation_degrees",rotation_degrees + (Rotation_Axis * 360), Rotation_speed)
			tween.tween_property(self, "rotation_degrees",start_rot, 0.01)
		elif Item_Motion == 2:
			tween.tween_property(self, "global_position",start_pos + (Bounce_axis * Bounce_height), Bounce_speed)
			tween.tween_property(self, "global_position",start_pos, Bounce_speed)
		tween.set_loops()
	else:
		tween.kill()

func Value_limit() -> void:
	## Function rounds any imput for bounce height to the nearest inter and claps it between 0 and 1
	Bounce_axis = Vector3(
		clamp(round(Bounce_axis.x), 0.0, 1.0),
		clamp(round(Bounce_axis.y), 0.0, 1.0),
		clamp(round(Bounce_axis.z), 0.0, 1.0)
		)

func on_body_entered(body: Node3D) -> void:
	## Function confirms if a variable name exists in the player node matching the Item name
	if body.is_in_group("player"):
		if body.get(Item_Name) != null:
			if Item_Type == 1:
				body.set(Item_Name,body.get(Item_Name) + Item_Amount)
				self.queue_free()
			if Item_Type == 2:
				temp_val = body.get(Item_Name)
				body.set(Item_Name,body.get(Item_Name) + Item_Amount)
				self.set_deferred("monitoring",false)
				self.hide()
				await get_tree().create_timer(Item_Power_Up_Time).timeout
				Revert(body)
	pass

func Revert(a) -> void:
	a.set(Item_Name,temp_val)
	self.queue_free()

func _exit_tree() -> void:
	tween.kill()
