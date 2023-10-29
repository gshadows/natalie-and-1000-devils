extends TextureRect

signal closed

@onready var _anim := $AnimationPlayer
@onready var _sfx := $MenuSFX
@onready var _music := $MenuMusic

@onready var _snd_click = preload("res://audio/MenuClick-fs-448080.wav")
@onready var _snd_hover = preload("res://audio/MenuHover-fs-420615.wav")

func _play_click():
	_sfx.stream = _snd_click
	_sfx.play()

func _play_hover():
	_sfx.stream = _snd_hover
	_sfx.play()

func _on_closed() -> void:
	_play_click()
	await _sfx.finished
	closed.emit()


func setup(is_win: bool) -> void:
	%ButtonNext.visible = is_win
	%ButtonEnd.visible = not is_win
	if is_win:
		$MusicWin.play()
	else:
		$MusicLoose.play()
