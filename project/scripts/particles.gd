extends Node

func _ready() -> void:
	for child in get_children():
		if child is GPUParticles3D:
			child.emitting = true

func _process(_delta: float) -> void:
	var any_emitting := false
	for child in get_children():
		if child is GPUParticles3D:
			if child.emitting:
				any_emitting = true
				break
	if not any_emitting:
		queue_free()
