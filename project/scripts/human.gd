extends CharacterBody3D
@export var speed = 4.0
@export var sprint_multiplier = 1.5
@export var sensitivity = 0.003
@export var jump_velocity = 5.0
@export var gravity = -9.8
@export var robot : Node
@export var footstep_interval = 0.5  # Time between footstep sounds
@export var footstep_sounds: Array[AudioStream] 
@export var jump_sound: AudioStream
@onready var camera = $Camera3D
@export var bobbing_intensity = 0.1
@export var bobbing_speed = 3.0  
var bobbing_transition_speed = 0.3
var initial_camera_y = 0.0           
var footstep_timer = 0.0 
var mouse_delta = Vector2.ZERO
var was_on_floor = true

func _ready():
	initial_camera_y = camera.transform.origin.y

func _input(event): # LOOK
	if event is InputEventMouseMotion and camera.current:
		mouse_delta += event.relative

func _physics_process(delta):
	if robot and camera.current:
		
		if mouse_delta.length() > 0: # Look
			rotate_y(-mouse_delta.x * sensitivity)  # Horizontal look (yaw)
			camera.rotate_x(-mouse_delta.y * sensitivity)  # Vertical look (pitch)
			camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)
			mouse_delta = Vector2.ZERO
		
		var direction = Vector3.ZERO # RUN
		if Input.is_action_pressed("forward"): direction -= transform.basis.z
		if Input.is_action_pressed("backward"): direction += transform.basis.z
		if Input.is_action_pressed("left"): direction -= transform.basis.x
		if Input.is_action_pressed("right"): direction += transform.basis.x
		if Input.is_action_pressed("sprint"): 
			direction = direction.normalized() * speed * sprint_multiplier
			footstep_timer -= delta * sprint_multiplier
			camera.fov += ((110 - camera.fov) * .1)
		elif direction.length() > 0:
			direction = direction.normalized() * speed
			footstep_timer -= delta
			camera.fov += ((100 - camera.fov) * .1)
		camera.fov += ((90 - camera.fov) * .1)
		velocity.x = direction.x
		velocity.z = direction.z
		
		var bob_target = initial_camera_y # Camera Bob
		if is_on_floor() and direction.length() > 0:
			bob_target = initial_camera_y + sin(Time.get_ticks_msec() / 1000.0 * bobbing_speed * direction.length()) * bobbing_intensity
			play_footstep()
		camera.transform.origin.y += (bob_target - camera.transform.origin.y) * bobbing_transition_speed
	
		if not was_on_floor and is_on_floor():
			play_footstep()
		was_on_floor = is_on_floor()
	
		if is_on_floor() and Input.is_action_just_pressed("jump"): # Jump
			velocity.y = jump_velocity 
			if jump_sound:
				var jump_audio = AudioStreamPlayer3D.new()
				jump_audio.stream = jump_sound
				jump_audio.global_transform = global_transform
				add_child(jump_audio)
				jump_audio.play()
				jump_audio.connect("finished", Callable(jump_audio, "queue_free"))

	velocity.y += gravity * delta 
	move_and_slide()

func play_footstep():
	if footstep_timer <= 0:
		if footstep_sounds.size() > 0:
			var footstep_audio = AudioStreamPlayer3D.new()
			footstep_audio.stream = footstep_sounds[randi() % footstep_sounds.size()]
			footstep_audio.global_transform = global_transform  
			footstep_audio.pitch_scale = randf_range(0.9, 1.1)
			add_child(footstep_audio)
			footstep_audio.play()
			footstep_audio.bus = "SFX" 
			footstep_audio.connect("finished", Callable(footstep_audio, "queue_free"))
			footstep_timer = footstep_interval
