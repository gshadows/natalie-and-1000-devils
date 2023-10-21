extends Node

signal started
signal continued
signal stopped
signal paused

@onready var AUDIO_BUS_MASTER = AudioServer.get_bus_index("Master")
@onready var AUDIO_BUS_MUSIC = AudioServer.get_bus_index("Music")
@onready var AUDIO_BUS_SFX = AudioServer.get_bus_index("SFX")

enum GAME_MODE { NONE, GAME, INTERTITLE, LOADING }
var mode: GAME_MODE = GAME_MODE.NONE
var mode_locked := false


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
