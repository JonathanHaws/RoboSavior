extends StaticBody3D
class_name FragileObject

@export var item_type : Interaction.ITEM_TYPE
@export var is_decal : bool = false

@export_group("Decal Settings")
@export var high_damage_decal : Texture2D
@export var medium_damage_decal : Texture2D
@export var low_damage_decal : Texture2D

@export_group("Mesh Settings")
@export var high_damage_mesh : Mesh
@export var medium_damage_mesh : Mesh
@export var low_damage_mesh : Mesh

var damage : int = 0

@export var FIX_COUNT : int = 3
var fix_tick : int = 0

@onready var DECAL : Decal = $Decal
@onready var MESH : MeshInstance3D = $Mesh

func _ready() -> void:
	if not is_decal:
		DECAL.hide()
		DECAL.process_mode = Node.PROCESS_MODE_DISABLED
		MESH.mesh = low_damage_mesh
		return

func _broke_one_level() -> void:
	damage += 1
	if damage > 2:
		damage = 2
	_update_visuals()

func _fix_one_level() -> void:
	damage -= 1
	if damage < 0:
		damage = 0
	_update_visuals()

func _try_to_fix() -> void:
	fix_tick += 1
	if fix_tick >= FIX_COUNT:
		fix_tick = 0
		_fix_one_level()

func _update_visuals():
	if is_decal:
		if damage == 0:
			DECAL.texture_albedo = low_damage_decal
		if damage == 1:
			DECAL.texture_albedo = medium_damage_decal
		if damage == 2:
			DECAL.texture_albedo = high_damage_decal
		return
	if damage == 0:
		MESH.mesh = low_damage_mesh
	if damage == 1:
		MESH.mesh = medium_damage_mesh
	if damage == 2:
		MESH.mesh = high_damage_mesh
