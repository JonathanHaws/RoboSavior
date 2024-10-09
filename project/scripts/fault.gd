extends Node3D
@export var hitbox: Area3D
@export var human: Node
@export var robot: Node
@export var sound_player: AudioStreamPlayer2D
@export var break_sounds: Array[AudioStream]  
@export var fix_sounds: Array[AudioStream]  
@export var fix_animation: String
var within_reach = false

func _ready() -> void:
	hitbox.area_entered.connect(_on_area_entered)
	hitbox.area_exited.connect(_on_area_exited) 
	
func _on_area_entered(_area: Node) -> void: 
	within_reach = true

func _on_area_exited(_area: Node) -> void: 
	within_reach = false

func _process(_delta: float) -> void: 
	if human.camera.current:
		if Input.is_action_just_pressed("repair"):
			if within_reach:
				if $Broken.visible == true:
					fix_damage()

func fix_damage() -> void:
	if $Broken.visible == false: return
	if fix_sounds.size() > 0:
		play_sound(fix_sounds[randi() % fix_sounds.size()])
	$Broken.visible = false
	$Fixed.visible = true
	human.camera.shake = 2;
	robot.health +=1
	if human.get_node("AnimationPlayer").has_animation(fix_animation): human.get_node("AnimationPlayer").play(fix_animation)

func take_damage() -> void:
	if break_sounds.size() > 0:
		play_sound(break_sounds[randi() % break_sounds.size()])
	$Broken.visible = true
	$Fixed.visible = false

func play_sound(sound: AudioStream) -> void:
	sound_player.stream = sound
	sound_player.pitch_scale = randf_range(0.9, 1.1)
	sound_player.play()
