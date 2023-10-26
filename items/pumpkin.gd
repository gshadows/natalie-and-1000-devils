class_name Pumpkin
extends Node3D

const MIN_PERIOD_MS = 1000
const MAX_PERIOD_MS = 2000

signal finished

@onready var _snd_shake = preload("res://audio/MenuClick-fs-448080.wav")
@onready var _snd_bite = preload("res://audio/MenuHover-fs-420615.wav")

@onready var _anim = $AnimationPlayer
@onready var _sfx = $AudioStreamPlayer

var _active := false
var _period_ms := 0
var _next_bite_time: int
var _size_left = 3


func _play(stream: AudioStream):
	_sfx.stream = stream
	_sfx.play()


func activate_devil() -> void:
	_period_ms = randi_range(MIN_PERIOD_MS, MAX_PERIOD_MS)
	_play(_snd_shake)
	_devil_wait()
	_active = true


func _devil_wait() -> void:
	_next_bite_time = Time.get_ticks_msec() + _period_ms
	_anim.play("shake")


func _process(_delta: float) -> void:
	if not _active: return
	if Time.get_ticks_msec() <= _next_bite_time: return
	_do_bite()


func _do_bite() -> void:
	_size_left -= 1
	_play(_snd_bite)
	if _size_left <= 0:
		get_parent().remove_child(self)
		finished.emit()
		queue_free()
		return
	match _size_left:
		2:
			$Pumpkin1.visible = false
			$Pumpkin23.visible = true
		1:
			$Pumpkin23.visible = false
			$Pumpkin13.visible = true
		_:
			$Pumpkin13.visible = false
	_devil_wait()
	return
