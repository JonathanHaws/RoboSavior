extends Node3D

@export var label_3d: Label3D
var time_passed: float = 0.0

func _process(delta: float) -> void:
	time_passed += delta
	var total_seconds = int(time_passed)
	var hours = total_seconds / 3600.0  # Use float division
	var minutes = (total_seconds % 3600) / 60.0  # Use float division
	var seconds = total_seconds % 60  # No division needed for seconds
	label_3d.text = "%02d:%02d:%02d" % [int(hours), int(minutes), seconds]
