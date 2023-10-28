extends Node

signal started
signal continued
signal stopped
signal paused

signal cheat_idkfa
signal cheat_idclip
signal cheat_flyfly
signal cheat_winwin
signal cheat_looser

@onready var AUDIO_BUS_MASTER = AudioServer.get_bus_index("Master")
@onready var AUDIO_BUS_MUSIC = AudioServer.get_bus_index("Music")
@onready var AUDIO_BUS_SFX = AudioServer.get_bus_index("SFX")

enum GAME_MODE { NONE, GAME, INTERTITLE, LOADING }
var mode: GAME_MODE = GAME_MODE.NONE
var mode_locked := false

var _cheats := "??????"
var is_god_mode := false
var is_nsfw := false
var is_flyfly := false

var score: Score


func _ready():
	Settings.audio_setup_updated.connect(_on_audio_setup_upd)
	Settings.video_setup_updated.connect(_on_video_setup_upd)

func _on_audio_setup_upd():
	AudioServer.set_bus_volume_db(AUDIO_BUS_MASTER, linear_to_db(Settings.audio.master_vol))
	AudioServer.set_bus_mute(AUDIO_BUS_MASTER, !Settings.audio.master_enabled)

	AudioServer.set_bus_volume_db(AUDIO_BUS_SFX, linear_to_db(Settings.audio.sfx_vol))
	AudioServer.set_bus_mute(AUDIO_BUS_SFX, !Settings.audio.sfx_enabled)

	AudioServer.set_bus_volume_db(AUDIO_BUS_MUSIC, linear_to_db(Settings.audio.music_vol))
	AudioServer.set_bus_mute(AUDIO_BUS_MUSIC, !Settings.audio.music_enabled)

func _on_video_setup_upd():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if Settings.video.full_screen else DisplayServer.WINDOW_MODE_MAXIMIZED)


func start() -> void:
	if mode == GAME_MODE.NONE:
		mode = GAME_MODE.GAME
		score = Score.new()
		started.emit()
	else:
		continued.emit()
	get_tree().paused = false

func stop() -> void:
	if mode == GAME_MODE.NONE:
		return
	get_tree().paused = true
	mode = GAME_MODE.NONE
	stopped.emit()

func pause() -> void:
	if mode == GAME_MODE.NONE:
		return
	get_tree().paused = true
	paused.emit()


func _input(event) -> void:
	if event is InputEventKey:
		if event.pressed and not event.echo:
			var key = OS.get_keycode_string(event.keycode)
			if key.length() == 1:
				_cheats = _cheats.substr(1) + key.to_upper()
				_check_cheats()

func _check_cheats() -> void:
	if _cheats.ends_with("IDDQD"):
		is_god_mode = not is_god_mode
		score.cheater = true
	elif _cheats.ends_with("IDKFA"):
		cheat_idkfa.emit()
		score.cheater = true
	elif _cheats.ends_with("IDCLIP"):
		cheat_idclip.emit()
	elif _cheats.ends_with("NSFW"):
		is_nsfw = not is_nsfw
	elif _cheats.ends_with("FLYFLY"):
		is_flyfly = not is_flyfly
		cheat_flyfly.emit()
	elif _cheats.ends_with("WINWIN"):
		score.cheater = true
		cheat_winwin.emit()
	elif _cheats.ends_with("LOOSER"):
		cheat_looser.emit()
	elif OS.is_debug_build() and _cheats.ends_with("666666"):
		score.cheater = false
