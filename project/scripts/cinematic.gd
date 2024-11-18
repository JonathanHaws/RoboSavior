extends AnimationPlayer
var cutscene_triggered = false

func _ready():
	play("Intro_Interior", 0.0, 1.0, false)

func _process(delta):
	if Input.is_action_just_pressed("steer") and not cutscene_triggered:
		cutscene_triggered = true
		play("Intro_Exterior",0.0 , 1.0, false)
