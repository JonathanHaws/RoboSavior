extends CharacterBody3D
@export var speed = 2.0
@export var explosion_scene : PackedScene
@export var robot : Node
@export var human : Node
@export var gravity = -9.8
@export var death_sound: AudioStream 
@onready var attack = $scorpion/Scorpion/Skeleton3D/BoneAttachment3D/Area3D
@onready var anim_player = $scorpion/AnimationPlayer
@onready var detection_range = $DetectionRange
@onready var nav_agent = $NavigationAgent3D
var in_range = false
var health = 3

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
		if anim_player.current_animation != "ATTACK" :
			if point_towards_robot(0.1) < 0.1: # only attacks when fully facing player
				anim_player.play("ATTACK", 0.2, 1.0, false) 
		
	elif anim_player.current_animation != "ATTACK":
		if NavigationServer3D.map_get_iteration_id(nav_agent.get_navigation_map()) > 0:
			if is_on_floor(): 
				nav_agent.target_position = robot.global_transform.origin
				var nav_velocity = nav_agent.get_next_path_position() - global_transform.origin
				nav_velocity = nav_velocity.normalized() * speed
				rotation.y = lerp_angle(rotation.y, atan2(nav_velocity.x, nav_velocity.z), 0.1)  # Gradual rotation
				velocity.x = nav_velocity.x
				velocity.z = nav_velocity.z
		
		if velocity.length() > 0 and is_on_floor():
			anim_player.play("CRAWL", 0.2, 1.0, false)
		else:
			anim_player.play("IDLE", 0.2, 1.0, false)  
			
	if is_on_floor(): velocity.y = 0  
	else: velocity.y += gravity * delta
	move_and_slide()
	
func _on_attack_entered(body):
	if body != self and body == robot : 
		if body.has_method("take_damage"): body.take_damage(1)
		
func take_damage(amount: float) -> void:
	health -= amount
	robot.camera.shake = 3; 
	if health <= 0: 
		var explosion = explosion_scene.instantiate()
		explosion.global_transform = global_transform
		get_tree().current_scene.add_child(explosion) 
		
		var death_audio = AudioStreamPlayer3D.new(); 
		death_audio.stream = death_sound; 
		death_audio.global_transform = global_transform; 
		get_tree().current_scene.add_child(death_audio); 
		death_audio.bus = "SFX"
		death_audio.play()
		death_audio.connect("finished", Callable(death_audio, "queue_free"))
		
		queue_free()
