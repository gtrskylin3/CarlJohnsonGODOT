@tool
extends EditorPlugin


func _enable_plugin() -> void:
	# Add autoloads here.
	pass

func _disable_plugin() -> void:
	# Remove autoloads here.
	pass

func _enter_tree() -> void:
	add_custom_type("Bounce Pad","Area3D",preload("res://addons/platfomer_starterkit/Bounce_Pad/bounce_pad.gd") ,preload("res://addons/platfomer_starterkit/Icons/bouncepad.svg"))
	add_custom_type("Item","Area3D",preload("res://addons/platfomer_starterkit/Item/item.gd") ,preload("res://addons/platfomer_starterkit/Icons/item.svg"))
	add_custom_type("Moving Platform","AnimatableBody3D",preload("res://addons/platfomer_starterkit/Moving_Platform/moving_platform.gd") ,preload("res://addons/platfomer_starterkit/Icons/moving_platform.svg"))
	add_custom_type("Checkpoint","Area3D",preload("res://addons/platfomer_starterkit/Checkpoint/check_point.gd") ,preload("res://addons/platfomer_starterkit/Icons/checkpoint.svg"))
	add_custom_type("Respawner","Area3D",preload("res://addons/platfomer_starterkit/Respawn/respawn.gd") ,preload("res://addons/platfomer_starterkit/Icons/restart.svg"))

	# Initialization of the plugin goes here.
	pass

func _exit_tree() -> void:
	remove_custom_type("Bounce Pad")
	remove_custom_type("Item")
	remove_custom_type("Moving Platform")
	remove_custom_type("Checkpoint")
	remove_custom_type("Respawner")
	# Clean-up of the plugin goes here.
	pass
