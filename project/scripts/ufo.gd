extends Node3D
@export var enemy_scenes: Array[PackedScene]
@export var enemy_weights: Array[int]
@export var robot: Node
@export var human : Node

func start_waves():
	$Waves.play("difficulty_increase", 0.0, 1.0, false)
	$Waves.seek(0.01, true)
	$Spawn_Timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	$Spawn_Timer.start($Spawn_Timer.wait_time)

func _on_timer_timeout(): 
	spawn_enemy()
	#print("Wait time:", $Spawn_Timer.wait_time) 
	#print("Time left:", $Spawn_Timer.time_left)
	
func spawn_enemy(enemy_index: int = -1):
	var selected_enemy_scene = null
	if enemy_index >= 0 and enemy_index < enemy_scenes.size():
		selected_enemy_scene = enemy_scenes[enemy_index]
	else:
		selected_enemy_scene = get_weighted_enemy_scene()
	
	if selected_enemy_scene:
		var enemy_instance = selected_enemy_scene.instantiate()
		if enemy_instance:
			var parent_node = get_parent()
			parent_node.add_child(enemy_instance) 
			enemy_instance.global_transform.origin = global_transform.origin
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

func _process(_delta):
	#print("Wait time:", $Spawn_Timer.wait_time) 
	#print("Time left:", $Spawn_Timer.time_left)
	pass
