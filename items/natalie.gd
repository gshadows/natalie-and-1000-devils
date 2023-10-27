class_name Natalie
extends Node3D

signal attack(x: float)

const INPUT_EPSILON := 0.01
const RUN_SPEED := 3.0
const JAR_Y_MOVEMENT := 0.5
const JAR_HANDS_ROTATION := PI / 6 # 30 deg

@onready var _anim := $AnimationPlayer
@onready var _sfx := $AudioStreamPlayer
@onready var _jar := $Jar
@onready var _skel := $"Natalie-RIG_deform/Skeleton3D"

var _x_min: int
var _x_max: int
var _base_jar_y: float
var _base_rotation: float
var _jar_pos: int # -1, 0, +1
var _spine_bone_idx: int
var _spine_pose: Transform3D


func _ready() -> void:
	_base_jar_y = _jar.position.y
	_base_rotation = 0
	_spine_bone_idx = _skel.find_bone("DEF-spine.001")
	_spine_pose = _skel.get_bone_global_pose_no_override(_spine_bone_idx)

func setup(xmin: float, xmax: float) -> void:
	_x_min = xmin
	_x_max = xmax


func _process(delta: float) -> void:
	_movement(delta, Input.get_axis("go_left", "go_right"))
	_jar_move(delta)


func _movement(delta: float, amount: float) -> void:
	if abs(amount) >= INPUT_EPSILON:
		amount *= RUN_SPEED * delta
		global_position.x = clampf(global_position.x + amount, _x_min, _x_max)
		global_rotation_degrees.y = signf(amount) * 90.0
		_anim.play("run")
	else:
		_anim.stop()


func _jar_move(delta: float) -> void:
	var dir := 0
	if Input.is_action_just_pressed("jar_up"):
		dir = +1
	elif Input.is_action_just_pressed("jar_down"):
		dir = -1
	if dir != 0:
		_jar_pos = clampi(_jar_pos + dir, -1.0, +1.0)
		_jar.position.y = _base_jar_y + _jar_pos * JAR_Y_MOVEMENT
		#var pose: Transform3D = _skel.get_bone_global_pose_no_override(_spine_bone_idx)
		var pose = _spine_pose.rotated_local(Vector3.LEFT, _jar_pos * JAR_HANDS_ROTATION)
		_skel.set_bone_global_pose_override(_spine_bone_idx, pose, 1.0, true)
