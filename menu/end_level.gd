extends TextureRect

signal closed

@onready var _sfx := $SFX

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
	fill_scores()


func fill_scores() -> void:
	%Devils.text = str(Game.score.devils_level)
	%DevilsOf.text = str(Game.level_devils)
	%DevilsTotal.text = str(Game.score.devils_total)
	%Pumpkins.text = str(Game.score.pumpkin_lost_level)
	%PumpkinsOf.text = str(Game.level_pumpkins)
	%PumpkinTotal.text = str(Game.score.pumpkin_lost_total)
	Game.score.pumpkin_score = (Game.level_pumpkins - Game.score.pumpkin_lost_level)
	%PumpkinScore.text = str("+", Game.score.pumpkin_score)
	var score := Game.score.devils_level + Game.score.pumpkin_score
	Game.score.total_score += score
	%Score.text = str(Game.score.total_score, "(+", score, ")")
