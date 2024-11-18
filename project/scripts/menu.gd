
# Make sure process mode for this script is 'always' so when game pauses it doesnt pause aswell
extends CanvasLayer
@export var main_menu: Control
@export var options_menu: Control
@export var controls_menu: Control
@export var credits_menu: Control
@export var hover_sound_player: AudioStreamPlayer2D
@export var pressed_sound_player: AudioStreamPlayer2D
@export var hover_sound: AudioStream
@export var pressed_sound: AudioStream
func resume() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	self.visible = false
	Engine.time_scale = 1
	get_tree().paused = false
func pause() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE 
	self.visible = true;
	Engine.time_scale = 0
	get_tree().paused = true
func restart() -> void:
	resume()
	get_tree().reload_current_scene()
func quit() -> void:
	get_tree().quit()
func options() -> void:
	main_menu.visible = false
	options_menu.visible = true
func controls() -> void:
	main_menu.visible = false
	controls_menu.visible = true
func credits() -> void:
	main_menu.visible = false
	credits_menu.visible = true
func options_back() -> void:
	main_menu.visible = true
	options_menu.visible = false
func controls_back() -> void:
	main_menu.visible = true
	controls_menu.visible = false
func credits_back() -> void:
	main_menu.visible = true
	credits_menu.visible = false
func master_changed(value: float) -> void:
	var master_bus = AudioServer.get_bus_index("Master")
	var db_value = lerp(-80, 0, pow(value / 100, 0.5))  
	AudioServer.set_bus_volume_db(master_bus, db_value)
	save_settings()
func music_changed(value: float) -> void:
	var music_bus = AudioServer.get_bus_index("Music")
	var db_value = lerp(-80, 0, pow(value / 100, 0.5))  #
	AudioServer.set_bus_volume_db(music_bus, db_value)
	save_settings()
func sfx_changed(value: float) -> void:
	var sfx_bus = AudioServer.get_bus_index("SFX")
	var db_value = lerp(-80, 0, pow(value / 100, 0.5)) 
	AudioServer.set_bus_volume_db(sfx_bus, db_value)
	save_settings()
func window_mode_changed(index: int) -> void:
	match index:
		0: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		1: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	save_settings()
func save_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("audio", "sfx_volume", options_menu.get_node("Sfx/Slider").value)
	config.set_value("audio", "music_volume", options_menu.get_node("Music/Slider").value)
	config.set_value("audio", "master_volume", options_menu.get_node("Master/Slider").value)
	config.set_value("options", "display", options_menu.get_node("Display").selected)
	config.save("user://settings.cfg")
func load_settings() -> void:
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK:
		var window_mode = config.get_value("options", "display", 0)
		var sfx_volume = config.get_value("audio", "sfx_volume", 100)
		var music_volume = config.get_value("audio", "music_volume", 100)
		var master_volume = config.get_value("audio", "master_volume", 100)
		options_menu.get_node("Display").select(window_mode)
		window_mode_changed(window_mode)
		options_menu.get_node("Sfx/Slider").value = sfx_volume
		sfx_changed(sfx_volume)
		options_menu.get_node("Music/Slider").value = music_volume
		music_changed(music_volume)
		options_menu.get_node("Master/Slider").value = master_volume
		master_changed(master_volume)
func play_hover_sound() -> void:
	$AudioStreamPlayer2D.stream = hover_sound; 
	$AudioStreamPlayer2D.play()
func play_pressed_sound() -> void:
	$AudioStreamPlayer2D.stream = pressed_sound; 
	$AudioStreamPlayer2D.play()

func _ready() -> void:
	load_settings()
	resume()
	main_menu.get_node("Resume").connect("pressed", Callable(self, "resume"))
	main_menu.get_node("Restart").connect("pressed", Callable(self, "restart"))
	main_menu.get_node("Options").connect("pressed", Callable(self, "options"))
	main_menu.get_node("Controls").connect("pressed", Callable(self, "controls"))
	main_menu.get_node("Credits").connect("pressed", Callable(self, "credits"))
	main_menu.get_node("Quit").connect("pressed", Callable(self, "quit"))  # Add this line
	options_menu.get_node("Back").connect("pressed", Callable(self, "options_back"))
	controls_menu.get_node("Back").connect("pressed", Callable(self, "controls_back"))
	credits_menu.get_node("Back").connect("pressed", Callable(self, "credits_back"))
	options_menu.get_node("Sfx/Slider").connect("value_changed", Callable(self, "sfx_changed"))
	options_menu.get_node("Music/Slider").connect("value_changed", Callable(self, "music_changed"))
	options_menu.get_node("Master/Slider").connect("value_changed", Callable(self, "master_changed"))
	options_menu.get_node("Display").connect("item_selected", Callable(self, "window_mode_changed"))
	
	# Recursively connect buttons for audio
	var all_nodes = get_children(); while all_nodes.size() > 0:
		var current_node = all_nodes.pop_back()
		if current_node is Button:
			current_node.connect("mouse_entered", Callable(self, "play_hover_sound"))
			current_node.connect("pressed", Callable(self, "play_pressed_sound"))
		all_nodes += current_node.get_children()
		
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		if self.visible:
			play_pressed_sound()
			resume()	
		else :
			play_pressed_sound()
			pause()
