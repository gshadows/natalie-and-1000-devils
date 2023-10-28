class_name Devil
extends Node3D

signal jarred

const MOVE_TIME_SEC := 1.0
const MIN_TIME := 2.0
const MAX_TIME := 7.0

@onready var _sfx := $AudioStreamPlayer
@onready var _anim := $AnimationPlayer
@onready var _timer := $Timer

@onready var _snd_scare = preload("res://audio/MenuClick-fs-448080.wav")
@onready var _snd_shar = preload("res://audio/MenuHover-fs-420615.wav")
@onready var _snd_jump = preload("res://audio/MenuHover-fs-420615.wav")

var _move_tween = null


func _play(stream: AudioStream):
	_sfx.stream = stream
	_sfx.play()


func on_revealed(target_pos: Vector3) -> void:
	_play(_snd_scare)
	_anim.play("jumping")
	await _anim.animation_finished
	jarred.emit()
	move_to(target_pos, _on_jarred)


func move_to(target_pos: Vector3, callback = null) -> void:
	if _move_tween:
		_move_tween.kill()
	_move_tween = create_tween()
	_move_tween.tween_property(self, "global_position", target_pos, MOVE_TIME_SEC).set_trans(Tween.TRANS_BOUNCE)
	if callback:
		_move_tween.tween_callback(callback)


func _on_jarred() -> void:
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
