extends CharacterBody3D
@export var speed = 3.0
@export var robot : Node
@export var human : Node
@export var gravity = -9.8
@export var hurt_particles : PackedScene
@export var death_particles : PackedScene
@export var death_sound: AudioStream 
@onready var attack = $Body/Area3D
@onready var anim_player = $AnimationPlayer
@onready var detection_range = $Body/DetectionRange
@onready var nav_agent = $NavigationAgent3D
var in_range = false
var health = 1

func _ready():
	detection_range.connect("body_entered", Callable(self, "_on_body_entered"))
	detection_range.connect("body_exited", Callable(self, "_on_body_exited"))
	attack.connect("body_entered", Callable(self, "_on_attack_entered"))
	call_deferred("point_towards_robot")

func _on_body_entered(body): if body == robot: in_range = true

func _on_body_exited(body): if body == robot: in_range = false

func point_towards_robot(interpolation_speed: float = 1.0):
	var direction = (robot.global_transform.origin - global_transform.origin).normalized()
	var target_y_rotation = atan2(direction.x, direction.z)
	rotation.y = lerp_angle(rotation.y, target_y_rotation, interpolation_speed)
	return abs(rotation.y - target_y_rotation) # returns remaining amount needed to directly face the player
	
func _physics_process(delta):
	if in_range:
		velocity.x = 0
		velocity.z = 0
		if anim_player.current_animation != "Attack" :
			if point_towards_robot(0.1) < 0.1: # only attacks when fully facing player
				anim_player.play("Attack", 0.0, 1.0, false) 
		
	elif anim_player.current_animation != "Attack":
		if NavigationServer3D.map_get_iteration_id(nav_agent.get_navigation_map()) > 0:
			if is_on_floor(): 
				nav_agent.target_position = robot.global_transform.origin
				var nav_velocity = nav_agent.get_next_path_position() - global_transform.origin
				nav_velocity = nav_velocity.normalized() * speed
				rotation.y = lerp_angle(rotation.y, atan2(nav_velocity.x, nav_velocity.z), 0.1)  # Gradual rotation
				velocity.x = nav_velocity.x
				velocity.z = nav_velocity.z
			
	if is_on_floor(): velocity.y = 0  
	else: velocity.y += gravity * delta
	move_and_slide()
	
func _on_attack_entered(body):
	if body != self and body == robot :
		human.get_node("Camera3D").shake = 1;  
		if body.has_method("take_damage"): body.take_damage(1)
		
func take_damage(amount: float) -> void:
	health -= amount
	robot.camera.shake = 3; 
	
	var hurt_particles_instance = hurt_particles.instantiate()
	hurt_particles_instance.global_transform = $Particles.global_transform
	get_tree().current_scene.add_child(hurt_particles_instance) 
	
	if health <= 0: 
		var death_particles_instance = death_particles.instantiate()
		death_particles_instance.global_transform = $Particles.global_transform
		get_tree().current_scene.add_child(death_particles_instance) 
		robot.camera.shake = 3; 
		
		var death_audio = AudioStreamPlayer3D.new(); 
		death_audio.stream = death_sound; 
		death_audio.global_transform = global_transform; 
		get_tree().current_scene.add_child(death_audio); 
		death_audio.bus = "SFX"
		death_audio.play()
		death_audio.connect("finished", Callable(death_audio, "queue_free"))
		queue_free()

func root_update_attack():
	var original_global_position = $Body.global_transform.origin
	anim_player.play("RESET", 0.0, 1, false)
	anim_player.advance(0)  # Immediately reset the animation
	var root_motion = original_global_position - $Body.global_transform.origin
	global_transform.origin += root_motion
