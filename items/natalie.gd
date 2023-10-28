class_name Natalie
extends Node3D

signal catching(x: float)

const EPSILON := 0.01 # floating point zero comparision threshold
const RUN_SPEED := 3.0
const JAR_Y_MOVEMENT := 0.5
const JAR_HANDS_ROTATION := PI / 6 # 30 deg

@onready var _anim := $AnimationPlayer
@onready var _sfx := $AudioStreamPlayer
@onready var _jar := $Jar
@onready var _skel := $"Natalie-RIG_deform/Skeleton3D"
@onready var _snd_step = preload("res://audio/MenuClick-fs-448080.wav")
@onready var _snd_catch = preload("res://audio/MenuHover-fs-420615.wav")

var _x_min: float
var _x_max: float
var _base_jar_y: float
var _base_rotation: float
var _jar_pos: int # -1, 0, +1
var _is_catching := false

var _spine_bone_idx: int
var _larm_bone_idx: int
var _rarm_bone_idx: int
var _spine_pose: Transform3D
var _larm_pose: Transform3D
var _rarm_pose: Transform3D


func _play(stream: AudioStream):
	_sfx.stream = stream
	_sfx.play()


func _ready() -> void:
	_base_jar_y = _jar.position.y
	_base_rotation = 0
	_spine_bone_idx = _skel.find_bone("DEF-spine.001")
	_larm_bone_idx  = _skel.find_bone("DEF-upper_arm.L")
	_rarm_bone_idx  = _skel.find_bone("DEF-upper_arm.R")
	_spine_pose = _skel.get_bone_global_pose_no_override(_spine_bone_idx)
	_larm_pose  = _skel.get_bone_global_pose_no_override(_larm_bone_idx)
	_rarm_pose  = _skel.get_bone_global_pose_no_override(_rarm_bone_idx)

func setup(xmin: float, xmax: float) -> void:
	_x_min = xmin
	_x_max = xmax


func _process(delta: float) -> void:
	_movement(delta, Input.get_axis("go_left", "go_right"))
	var catch_changed := _catch(delta)
	_jar_move(delta, catch_changed)


func _movement(delta: float, amount: float) -> void:
	if abs(amount) >= EPSILON:
		amount *= RUN_SPEED * delta
		global_position.x = clampf(global_position.x + amount, _x_min, _x_max)
		global_rotation_degrees.y = signf(amount) * 90.0
		_anim.play("run")
		if not _sfx.playing: _play(_snd_step)
	else:
		_anim.stop()


func _jar_move(_delta: float, catch_changed: bool) -> void:
	# Jar movement direction.
	var dir := 0
	if Input.is_action_just_pressed("jar_up"):
		dir = +1
	elif Input.is_action_just_pressed("jar_down"):
		dir = -1
	
	# Additional offest for catching.
	var catch_pos := 0 if not catch_changed else -1 if _is_catching else +1
	
	# Decide final body rotation and jar position.
	if dir != 0:
		_jar_pos = clampi(_jar_pos + dir, -1, +1) + catch_pos
	elif (catch_changed):
		_jar_pos += catch_pos
	else:
		return

	# Apply body rotation and jar position.
	_rotate_body(_jar_pos * JAR_HANDS_ROTATION)
	_jar.position.y = _base_jar_y + _jar_pos * JAR_Y_MOVEMENT


func _rotate_body(radians: float) -> void:
	_rotate_bone(radians, _spine_pose, _spine_bone_idx)
	#_rotate_bone(-radians, _larm_pose, _larm_bone_idx)
	#_rotate_bone(-radians, _rarm_pose, _rarm_bone_idx)

func _rotate_bone(radians: float, start_pose: Transform3D, bone_idx: int) -> void:
	#var start_pose: Transform3D = _skel.get_bone_global_pose_no_override(bone_idx)
	var pose = start_pose.rotated_local(Vector3.LEFT, radians)
	_skel.set_bone_global_pose_override(bone_idx, pose, 1.0, true)


# Returns true on catching state change.
func _catch(_delta: float) -> bool:
	if Input.is_action_just_pressed("catch"):
		var jar_x: float = _jar.global_position.x
		catching.emit(jar_x)
		_play(_snd_catch)
		_is_catching = true
		return true
	elif Input.is_action_just_released("catch"):
		_is_catching = false
		return true
	else:
		return false
