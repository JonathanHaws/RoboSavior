extends CharacterBody3D
@export var sensitivity = 0.003
@export var jump_velocity = 5.0
@export var gravity = -9.8
@export var projectile_scene : PackedScene
@export var human : Node
@export var faults : Node
@export var footstep_sounds: Array[AudioStream] 
@export var break_sounds: Array[AudioStream]  
@export var cinematic: AnimationPlayer
@export var look_influence = 0.0
@onready var camera = $Pivot/SpringArm3D/Camera3D
@onready var anim_player = $AnimationPlayer
@onready var skeleton_anim_player = $Mesh/AnimationPlayer
@onready var attack = $Mesh/Armature/Skeleton3D/BoneAttachment3D/Area3D
var mouse_delta = Vector2.ZERO # Only update oretientation in physics process so spring arm can collide correctly
var health = 3;

func _ready():
	attack.connect("area_entered", Callable(self, "_on_attack_entered"))
	
func _input(event): # LOOK
	if event is InputEventMouseMotion and camera.current :
		mouse_delta += event.relative

func _physics_process(delta):
	
	if camera.current : 
		
		if mouse_delta.length() > 0: # Look
			var y_rot = Quaternion(Vector3.UP, -mouse_delta.x * sensitivity * look_influence) 
			var x_rot = Quaternion($Pivot.transform.basis.x.normalized(), -mouse_delta.y * sensitivity * look_influence)
			$Pivot.transform.basis = Basis(y_rot) * Basis(x_rot) * $Pivot.transform.basis
			mouse_delta = Vector2.ZERO
		
		if Input.is_action_just_pressed("steer"):
			if anim_player.current_animation not in ["Punch", "Intro", "Defeat"]: 
				if anim_player.current_animation != "Retreat":
					anim_player.play("Retreat", -1, 1.0, false)	
			
		#if is_on_floor() and Input.is_action_just_pressed("jump"): 	
			#velocity.y = jump_velocity
			
		if Input.is_action_just_pressed("punch") and is_on_floor() and anim_player.current_animation not in ["Intro","Steer", "Defeat", "Retreat", "Punch", "Hurt"]:
			velocity.x = 0
			velocity.z = 0
			anim_player.stop()
			anim_player.play("Punch", -1, 1.0, false)
			skeleton_anim_player.play("Punch", -1, 1.0, 0.0) 
		
		if anim_player.current_animation not in ["Intro", "Steer", "Defeat", "Retreat", "Punch", "Hurt"]: # Run
			if Input.is_action_pressed("forward") or Input.is_action_pressed("backward") or Input.is_action_pressed("left") or Input.is_action_pressed("right"):
				anim_player.play("Run", -1, 1.0, 0.0) 
				skeleton_anim_player.play("Run", 0.1, 1.0, false)	
				var direction = Vector3.ZERO
				direction -= $Pivot.global_transform.basis.z * (int(Input.is_action_pressed("forward")) - int(Input.is_action_pressed("backward")))
				direction -= $Pivot.global_transform.basis.x * (int(Input.is_action_pressed("left")) - int(Input.is_action_pressed("right")))
				var flat_direction = Vector3(direction.x, 0, direction.z).normalized() # Reorient the mesh to face movement
				$Mesh.rotation.y = lerp_angle($Mesh.rotation.y, atan2(flat_direction.x, flat_direction.z) + PI, 8.0 * delta)
		
		if anim_player.current_animation not in ["Intro", "Steer", "Defeat", "Retreat", "Punch", "Hurt"]: # Idle
			if not (Input.is_action_pressed("forward") or Input.is_action_pressed("backward") or Input.is_action_pressed("left") or Input.is_action_pressed("right")):
				if anim_player.current_animation != "Idle":
					anim_player.play("Idle", -1, 1.0, false)
					skeleton_anim_player.play("Idle", .8, 1.0, false)	
					
	else:
		
		if Input.is_action_just_pressed("steer"):
			if anim_player.current_animation not in ["Intro", "Steer", "Defeat"]:
				if health > 0:
					anim_player.play("Steer", 0.0, 1.0, false)	
					skeleton_anim_player.play("Steer", 0.0, 1.0, false)	
	
	var root_motion_position = skeleton_anim_player.get_root_motion_position() 
	var transformed_root_motion = $Mesh.global_transform.basis * root_motion_position
	global_transform.origin += transformed_root_motion; 
	#if anim_player.current_animation == "Run": print(root_motion_position) # Fix stutter with root motion
	
	velocity.y += gravity * delta 
	move_and_slide()

func _on_attack_entered(body):	
	if body != self: #bandaid fix for when hitboxs are nested children of script... probably a smarter way to do this
		if body.has_method("take_damage"): body.take_damage(1)			
		elif body.get_parent() and body.get_parent().has_method("take_damage"): body.get_parent().take_damage(1)
		elif body.get_parent() and body.get_parent().get_parent() and body.get_parent().get_parent().has_method("take_damage"): body.get_parent().get_parent().take_damage(1)
		
func take_damage(_amount: float) -> void:
	#print(health)
	var faults_shuffled = faults.get_children()
	faults_shuffled.shuffle()
	for fault in faults_shuffled:
		if not fault.get_node("Broken").visible:
			human.get_node("Camera3D").shake = 2; 
			camera.shake = 2; 
			fault.take_damage()	
			anim_player.play("Hurt", -1, 1.0, false)
			health -= 1;	
			return;
	if health < 1:
		cinematic.play("Defeat", 0.0, 1.0, false)

func play_footstep():
	if footstep_sounds.size() > 0:
		var footstep_audio = AudioStreamPlayer3D.new()
		footstep_audio.stream = footstep_sounds[randi() % footstep_sounds.size()]
		footstep_audio.global_transform = global_transform  
		add_child(footstep_audio)
		footstep_audio.bus = "SFX" 
		footstep_audio.play()
		footstep_audio.connect("finished", Callable(footstep_audio, "queue_free"))
