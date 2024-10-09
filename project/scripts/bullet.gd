extends Area3D

@export var speed: float = 10.0
@export var lifespan: float = 5.0  
@export var damage: float = 1.0
var elapsed_time: float = 0.0

func _ready() -> void:
	elapsed_time = 0.0
	connect("body_entered", Callable(self, "_on_body_entered"))

func _process(delta: float) -> void:
	var movement = -transform.basis.z * speed * delta
	position += movement
	elapsed_time += delta 
	if elapsed_time > lifespan:
		queue_free() 
		
func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
