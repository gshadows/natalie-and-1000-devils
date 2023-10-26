class_name Devil
extends Node3D

signal jarred

const MIN_TIME := 2.0
const MAX_TIME := 7.0

@onready var _sfx := $AudioStreamPlayer
@onready var _anim := $AnimationPlayer
@onready var _timer := $Timer

@onready var _snd_scare = preload("res://audio/MenuClick-fs-448080.wav")
@onready var _snd_shar = preload("res://audio/MenuHover-fs-420615.wav")
@onready var _snd_jump = preload("res://audio/MenuHover-fs-420615.wav")

var _is_in_jar := false


func _play(stream: AudioStream):
	_sfx.stream = stream
	_sfx.play()


func on_revealed() -> void:
	_play(_snd_scare)
	_anim.play("jumping")
	await _anim.animation_finished
	jarred.emit()


func on_jarred() -> void:
	_is_in_jar = true
	while not is_queued_for_deletion():
		_timer.start(randf_range(MIN_TIME, MAX_TIME))
		await _timer.timeout
		if randi() % 20 == 0:
			_play(_snd_jump)
			_anim.play("jumping")
		else:
			_play(_snd_shar)
			_anim.play("sharoebica")
		await _anim.animation_finished
