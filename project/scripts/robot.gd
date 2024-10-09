extends CharacterBody3D
@export var sensitivity = 0.003
@export var jump_velocity = 5.0
@export var gravity = -9.8
@export var projectile_scene : PackedScene
@export var human : Node
@export var faults : Node
@export var footstep_sounds: Array[AudioStream] 
@export var break_sounds: Array[AudioStream]  
@onready var camera = $Pivot/SpringArm3D/Camera3D
@onready var anim_player = $Mesh/AnimationPlayer
@onready var attack = $Mesh/Armature/Skeleton3D/BoneAttachment3D/Area3D
var mouse_delta = Vector2.ZERO # Only update oretientation in physics process so spring arm can collide correctly
var health = 0;

func _ready():
	anim_player.play("Intro", 0.5, 1.0, false)
	attack.connect("body_entered", Callable(self, "_on_attack_entered"))
	
func _input(event): # LOOK
	if event is InputEventMouseMotion and camera.current :
		mouse_delta += event.relative

func _physics_process(delta):
	
	if mouse_delta.length() > 0: # Look
		if anim_player.current_animation not in ["Intro"]:
			var y_rot = Quaternion(Vector3.UP, -mouse_delta.x * sensitivity) 
			var x_rot = Quaternion($Pivot.transform.basis.x.normalized(), -mouse_delta.y * sensitivity)
			$Pivot.transform.basis = Basis(y_rot) * Basis(x_rot) * $Pivot.transform.basis
		mouse_delta = Vector2.ZERO
	
	if camera.current : 
		
		if Input.is_action_just_pressed("steer"):
			if anim_player.current_animation not in ["Punch", "Intro", "Defeat"]: 
				if anim_player.current_animation != "Retreat":
					anim_player.play("Retreat", 0.5, 1.0, false)	
			
		#if is_on_floor() and Input.is_action_just_pressed("jump"): 	
			#velocity.y = jump_velocity
			
		if Input.is_action_just_pressed("punch") and is_on_floor() and anim_player.current_animation not in ["Intro","Steer", "Defeat", "Retreat", "Punch"]:
			velocity.x = 0
			velocity.z = 0
			anim_player.stop()
			anim_player.play("Punch", 0.2, 1.0, false)
		
		if anim_player.current_animation not in ["Intro", "Steer", "Defeat", "Retreat", "Punch"]: # Run
			if Input.is_action_pressed("forward") or Input.is_action_pressed("backward") or Input.is_action_pressed("left") or Input.is_action_pressed("right"):
				anim_player.play("Run", 0.0, 1.0, 0.0) 
				var direction = Vector3.ZERO
				direction -= $Pivot.global_transform.basis.z * (int(Input.is_action_pressed("forward")) - int(Input.is_action_pressed("backward")))
				direction -= $Pivot.global_transform.basis.x * (int(Input.is_action_pressed("left")) - int(Input.is_action_pressed("right")))
				var flat_direction = Vector3(direction.x, 0, direction.z).normalized() # Reorient the mesh to face movement
				$Mesh.rotation.y = lerp_angle($Mesh.rotation.y, atan2(flat_direction.x, flat_direction.z) + PI, 8.0 * delta)
		
		if anim_player.current_animation not in ["Intro", "Steer", "Defeat", "Retreat", "Punch"]: # Idle
			if not (Input.is_action_pressed("forward") or Input.is_action_pressed("backward") or Input.is_action_pressed("left") or Input.is_action_pressed("right")):
				anim_player.play("Idle", 0.2, 1.0, 0.0) 
					
	else:
		
		if Input.is_action_just_pressed("steer"):
			anim_player.play("Steer", 0.0, 1.0, false)	
	
	var root_motion_position = anim_player.get_root_motion_position() 
	var transformed_root_motion = $Mesh.global_transform.basis * root_motion_position
	global_transform.origin += transformed_root_motion; 
	#if anim_player.current_animation == "Run": print(root_motion_position) // Fix stutter with root motion
	
	velocity.y += gravity * delta 
	move_and_slide()

func _on_attack_entered(body):	
	if body != self:
		if body.has_method("take_damage"): body.take_damage(1)			

func take_damage(_amount: float) -> void:
	var faults_shuffled = faults.get_children()
	faults_shuffled.shuffle()
	for fault in faults_shuffled:
		if not fault.get_node("Broken").visible:
			human.get_node("Camera3D").shake = 2; 
			camera.shake = 2; 
			fault.take_damage()	
			health -= 1;	
			return;
	if health < 1:
		anim_player.play("Defeat", 0.2, 1.0, false)

func play_footstep():
	if footstep_sounds.size() > 0:
		var footstep_audio = AudioStreamPlayer3D.new()
		footstep_audio.stream = footstep_sounds[randi() % footstep_sounds.size()]
		footstep_audio.global_transform = global_transform  
		add_child(footstep_audio)
		footstep_audio.bus = "SFX" 
		footstep_audio.play()
		footstep_audio.connect("finished", Callable(footstep_audio, "queue_free"))

func restart_game():
	get_tree().reload_current_scene()
