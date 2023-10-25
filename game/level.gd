extends Node3D

@export var shelf_left: Node3D
@export var shelf_right: Node3D
@export var markers: Array[Node3D]

@onready var _pumpkin_scene := preload("res://items/pumpkin.tscn")
@onready var _pumpkins := $Pumpkins


func _ready() -> void:
	for marker in markers:
		var p: Node3D = _pumpkin_scene.instantiate()
		p.global_position = marker.global_position
		_pumpkins.add_child(p)
