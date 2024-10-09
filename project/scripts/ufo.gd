extends Node3D
@export var enemy_scene: PackedScene
@export var explosion_scene: PackedScene
@export var robot: Node
@export var human : Node

func _ready():
	$Spawn_Timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	$Waves.play("difficulty_increase", -1.0, 1.0)

func _on_timer_timeout(): # Spawn Enemy
	spawn_enemy()
	
func spawn_enemy():
	if enemy_scene:
		var enemy_instance = enemy_scene.instantiate()
		if enemy_instance:
			var parent_node = get_parent()
			parent_node.add_child(enemy_instance) 
			enemy_instance.global_transform.origin = global_transform.origin
			enemy_instance.explosion_scene = explosion_scene
			enemy_instance.robot = robot
			enemy_instance.human = human
			
			
