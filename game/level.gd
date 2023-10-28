extends Node3D

signal win
signal loose

const CATCH_DISTANCE := 0.5

@export_category("Scene Configuration")
# Markers below will be deleted after _ready()
@export var shelf_left: Node3D
@export var shelf_right: Node3D
@export var x_limit_left: Node3D
@export var x_limit_right: Node3D

@export_category("Level Difficulty")
@export var devils_count := 10
@export var concurrent_devils := 2
@export var start_delay_sec := 5

@onready var _pumpkin_scene := preload("res://items/pumpkin.tscn")
@onready var _devil_scene := preload("res://items/devil.tscn")
@onready var _pumpkins: Node3D = $Pumpkins
@onready var _natalie: Natalie = $Natalie

var _jar_x1: Vector3
var _jar_x2: Vector3
var _shelf: Node3D
var _pumpkin_transforms_initial := []
var _cought := 0


func _ready() -> void:
	# Prepare jar shelf.
	_jar_x1 = shelf_left.global_position
	_jar_x2 = shelf_right.global_position
	shelf_left.queue_free()
	shelf_right.queue_free()
	_shelf = Node3D.new()
	_shelf.name = "Shelf"
	add_child(_shelf)
	
	# Init player
	_natalie.setup(x_limit_left.global_position.x, x_limit_right.global_position.x)
	x_limit_left.queue_free()
	x_limit_right.queue_free()

	# Clear unneeded objects.
	$Markers.queue_free()
	
	# Prepare pumpkins.
	_init_pumpkins()
	await get_tree().create_timer(start_delay_sec).timeout
	for i in concurrent_devils:
		_next_devil() # Activate random devil after random delay.

func _init_pumpkins() -> void:
	_pumpkin_transforms_initial.clear() # It should be initially clear, but just for safety.
	for pumpkin in _pumpkins.get_children():
		_pumpkin_transforms_initial.push_back(pumpkin.global_transform)

func _recreate_pumpkins() -> void:
	# Clear everything.
	for old_pumpkin_untyped in _pumpkins.get_children():
		var old_pumpkin := old_pumpkin_untyped as Pumpkin # To make autocompletion work :)
		_pumpkins.remove_child(old_pumpkin)
		if old_pumpkin.finished.is_connected(_pumpkin_finished):
			old_pumpkin.finished.disconnect(_pumpkin_finished)
		old_pumpkin.queue_free()
	# Create new pumpkins.
	for trans in _pumpkin_transforms_initial:
		var pumpkin = _pumpkin_scene.instantiate()
		pumpkin.global_transform = trans
		_pumpkins.add_child(pumpkin)


func _pumpkin_finished() -> void:
	_next_devil()


func _next_devil() -> void:
	var count = _pumpkins.get_child_count()
	if count == 0:
		loose.emit()
		return
	if count < concurrent_devils:
		return # No more pumpkins to haunt
	var pumpkin = _pumpkins.get_child(randi() % count) as Pumpkin
	pumpkin.activate_devil()
	pumpkin.finished.connect(_pumpkin_finished)


func _on_natalie_catching(x: float) -> void:
	for pumpkin in _pumpkins.get_children():
		if absf(x - pumpkin.global_position.x) <= CATCH_DISTANCE:
			_caught(pumpkin)
			return
	# Missed


func _caught(pumpkin: Pumpkin) -> void:
	# Notify pumpkin that devil was caught.
	pumpkin.on_catch()
	# Move all jars to make place for a new one.
	var delta_pos = (_jar_x2 - _jar_x1) / (_shelf.get_child_count() + 2)
	var pos := _jar_x1
	for jar in _shelf.get_children():
		(jar as Devil).move_to(pos)
		pos += delta_pos
	# Finally add new jar with devil.
	var devil := _devil_scene.instantiate()
	devil.name = "Devil"
	_shelf.add_child(devil)
	devil.on_revealed(pos)
	await devil.jarred # Wait until devil scare animation finished.
	_cought += 1
	if _cought >= devils_count:
		win.emit()
	else:
		_next_devil()
