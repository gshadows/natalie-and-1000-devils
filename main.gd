extends Node

@export_file("*.tscn") var GAME_START_SCENE = "res://game/level_01.tscn"
@export_file("*.tscn") var END_LEVEL_SCENE = "res://menu/end_level.tscn"

@onready var _menu = $MainMenu
var _game: Node


func _ready():
	if OS.is_debug_build() and (DisplayServer.get_screen_count() > 1):
		DisplayServer.window_set_current_screen(DisplayServer.window_get_current_screen() ^ 1)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	get_tree().paused = true
	Game.started.connect(_on_start)
	Game.continued.connect(_on_continue)
	Game.stopped.connect(_on_stop)
	Game.paused.connect(_on_pause)
	_menu.on_show()


func _on_start() -> void:
	_menu.visible = false
	_on_load_game(GAME_START_SCENE)

func _on_load_game(scene_path: String) -> void:
	if _game: _game.queue_free()
	_game = load(scene_path).instantiate()
	add_child(_game)
	if _game is Level:
		_game.win.connect(_level_win)
		_game.loose.connect(_level_loose)

func _level_loose() -> void:
	_on_load_game(END_LEVEL_SCENE)
	_game.closed.connect(_on_stop)
	_game.setup(false)

func _level_win() -> void:
	var next_level = _game.next_level
	_on_load_game(END_LEVEL_SCENE)
	if not next_level or (next_level == ""):
		_game.closed.connect(_on_stop)
	else:
		_game.closed.connect(_on_load_game.bind(next_level))
	_game.setup(true)

func _level_switch() -> void:
	pass

func _on_continue() -> void:
	_menu.visible = false
	_game.visible = true

func _on_stop() -> void:
	_menu.visible = true
	_menu.on_show()
	_game.queue_free()
	_game = null

func _on_pause() -> void:
	_menu.visible = true
	_menu.on_show()
	_game.visible = false
