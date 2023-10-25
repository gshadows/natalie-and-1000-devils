extends Node3D

signal finished

@onready var _snd_shake = preload("res://audio/MenuClick-fs-448080.wav")
@onready var _snd_bite = preload("res://audio/MenuHover-fs-420615.wav")

@onready var _anim = $AnimationPlayer
@onready var _sfx = $AudioStreamPlayer

var _active := false
var _period_ms := 0.0
var _next_bite_time: int
var _size_left = 3


func _play(stream: AudioStream):
	_sfx.stream = stream
	_sfx.play()


func activate_devil(period_ms: int) -> void:
	_period_ms = period_ms
	_play(_snd_shake)
	_devil_wait()
	_active = true


func _devil_wait() -> void:
	_next_bite_time = Time.get_ticks_msec() + _period_ms
	_anim.play("shake")


func _process(delta: float) -> void:
	if not _active: return
	if Time.get_ticks_msec() <= _next_bite_time: return
	_do_bite()


func _do_bite() -> void:
	_size_left -= 1
	_play(_snd_bite)
	if _size_left <= 0:
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
