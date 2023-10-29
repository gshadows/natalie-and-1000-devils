extends Control

@onready var _anim := $AnimationPlayer
@onready var _stop := %ButtonStop
@onready var _sfx := $MenuSFX
@onready var _music := $MenuMusic

@onready var _snd_click = preload("res://audio/MenuClick-fs-448080.wav")
@onready var _snd_hover = preload("res://audio/MenuHover-fs-420615.wav")

func on_show() -> void:
	if Settings.audio.music_enabled: _music.play()
	_stop.visible = (Game.mode != Game.GAME_MODE.NONE)
	_enable_settings(false)
	$InfoPanel.visible = false
	$SettingsPanel.visible = false


func _play_click():
	_sfx.stream = _snd_click
	_sfx.play()

func _play_hover():
	_sfx.stream = _snd_hover
	_sfx.play()


func _on_button_quit_pressed():
	_music.stop()
	_play_click()
	await get_tree().create_timer(0.2).timeout
	get_tree().quit(0)


func _on_start_stop_hover_mouse_entered() -> void:
	if Game.mode == Game.GAME_MODE.NONE: return
	_anim.play("show_stop")
	await _anim.animation_finished
	_stop.disabled = false

func _on_start_stop_hover_mouse_exited() -> void:
	if Game.mode == Game.GAME_MODE.NONE: return
	_stop.disabled = true
	_anim.play_backwards("show_stop")


func _on_button_start_pressed() -> void:
	_music.stop()
	_play_click()
	await get_tree().create_timer(0.2).timeout
	Game.start()

func _on_button_stop_pressed() -> void:
	_stop.visible = false
	Game.stop()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if not get_tree().paused:
			Game.pause()
		elif Game.mode != Game.GAME_MODE.NONE:
			_music.stop()
			Game.start()
		elif $InfoPanel.visible:
			_on_button_thanks_pressed()
		elif $SettingsPanel.visible:
			_on_button_ok_pressed()


func _on_button_settings_pressed() -> void:
	_play_click()
	$SettingsPanel.visible = true
	%FullScreen.set_pressed_no_signal(Settings.video.full_screen)
	%MasterEnable.set_pressed_no_signal(Settings.audio.master_enabled)
	%SfxEnable.set_pressed_no_signal(Settings.audio.sfx_enabled)
	%MusicEnable.set_pressed_no_signal(Settings.audio.music_enabled)
	%VolMaster.set_value_no_signal(Settings.audio.master_vol)
	%VolSfx.set_value_no_signal(Settings.audio.sfx_vol)
	%VolMusic.set_value_no_signal(Settings.audio.music_vol)
	_anim.play("show_settings")
	await _anim.animation_finished
	_enable_settings(true)

func _enable_settings(enable: bool) -> void:
	%ButtonOk.disabled = !enable
	%FullScreen.disabled = !enable
	%MasterEnable.disabled = !enable
	%VolMaster.editable = enable
	%SfxEnable.disabled = !enable
	%VolSfx.editable = enable
	%MusicEnable.disabled = !enable
	%VolMusic.editable = enable


func _on_full_screen_toggled(checked):
	_play_click()
	Settings.video.full_screen = checked
	Settings.video_setup_updated.emit()
	Settings.save()



func _on_master_enable_toggled(checked):
	_play_click()
	Settings.audio.master_enabled = checked
	Settings.audio_setup_updated.emit()
	Settings.save()

func _on_sfx_enable_toggled(checked):
	_play_click()
	Settings.audio.sfx_enabled = checked
	Settings.audio_setup_updated.emit()
	Settings.save()

func _on_music_enable_toggled(checked):
	_play_click()
	Settings.audio.music_enabled = checked
	Settings.audio_setup_updated.emit()
	Settings.save()
	if checked:
		_music.play()
	else:
		_music.stop()

func _on_vol_master_value_changed(value):
	if not Settings.audio.music_enabled: _play_click()
	Settings.audio.master_vol = value
	Settings.audio_setup_updated.emit()
	Settings.save()

func _on_vol_sfx_value_changed(value):
	_play_click()
	Settings.audio.sfx_vol = value
	Settings.audio_setup_updated.emit()
	Settings.save()

func _on_vol_music_value_changed(value):
	Settings.audio.music_vol = value
	Settings.audio_setup_updated.emit()
	Settings.save()


func _on_button_ok_pressed() -> void:
	_play_click()
	_enable_settings(false)
	_anim.play_backwards("show_settings")
	await _anim.animation_finished
	$SettingsPanel.visible = false


func _on_button_info_pressed():
	_play_click()
	$InfoPanel.visible = true
	_anim.play("show_info")
	await _anim.animation_finished


func _on_button_thanks_pressed():
	_play_click()
	_enable_settings(false)
	_anim.play_backwards("show_info")
	await _anim.animation_finished
	$InfoPanel.visible = false
