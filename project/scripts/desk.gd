extends Node3D
@export var robot : Node
@export var label_3d: Label3D
var time_passed: float = 0.0
var timer_started: bool = false

func _process(delta: float) -> void:
	if robot.health <= 0: return
	if Input.is_action_just_pressed("steer"): timer_started = true
	if !timer_started: return
	
	time_passed += delta
	var total_seconds = int(time_passed)
	var hours = total_seconds / 3600.0  # Use float division
	var minutes = (total_seconds % 3600) / 60.0  # Use float division
	var seconds = total_seconds % 60  # No division needed for seconds
	label_3d.text = "%02d:%02d:%02d" % [int(hours), int(minutes), seconds]
