extends Node3D
@export var enemy_scenes: Array[PackedScene]
@export var enemy_weights: Array[int]
@export var explosion_scene: PackedScene
@export var robot: Node
@export var human : Node

func _ready():
	$Spawn_Timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	$Waves.play("difficulty_increase", -1.0, 1.0)

func _on_timer_timeout(): # Spawn Enemy
	spawn_enemy()
	
func spawn_enemy():
	var selected_enemy_scene = get_weighted_enemy_scene()
	if selected_enemy_scene:
		var enemy_instance = selected_enemy_scene.instantiate()
		if enemy_instance:
			var parent_node = get_parent()
			parent_node.add_child(enemy_instance) 
			enemy_instance.global_transform.origin = global_transform.origin
			enemy_instance.explosion_scene = explosion_scene
			enemy_instance.robot = robot
			enemy_instance.human = human

func get_weighted_enemy_scene() -> PackedScene:
	var total_weight = 0
	for weight in enemy_weights:
		total_weight += weight
	var random_value = randi() % total_weight
	for i in enemy_weights.size():
		random_value -= enemy_weights[i]
		if random_value < 0:
			return enemy_scenes[i]
	return null
