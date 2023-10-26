extends Node3D

signal loose

const MIN_START_TIME = 3
const MAX_START_TIME = 5

# Markers below will be deleted after _ready()
@export var shelf_left: Node3D
@export var shelf_right: Node3D

@onready var _pumpkins := $Pumpkins

var _jar_x1: float
var _jar_x2: float


func _ready() -> void:
	# Process jar markers.
	_jar_x1 = shelf_left.global_position.x
	_jar_x2 = shelf_right.global_position.x
	shelf_left.queue_free()
	shelf_right.queue_free()
	
	# Cleanup group
	$Markers.queue_free()
	
	# Finally, activate random devil after delay.
	_next_devil()

func _next_devil() -> void:
	var count = _pumpkins.get_child_count()
	if count == 0:
		loose.emit()
		return
	await get_tree().create_timer(randf_range(MIN_START_TIME, MAX_START_TIME)).timeout
	var pumpkin = _pumpkins.get_child(randi() % count) as Pumpkin
	pumpkin.activate_devil()
	pumpkin.finished.connect(_next_devil)
