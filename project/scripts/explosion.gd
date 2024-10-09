extends Node

func _ready() -> void:
	$Fire.emitting = true
	$Embers.emitting = true

func _process(_delta: float) -> void:
	if not $Fire.emitting and not $Embers.emitting:
		queue_free()
