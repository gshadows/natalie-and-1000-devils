extends Node

@export_file("*.tscn") var GAME_START_SCENE = "res://game/level_01.tscn"

@onready var _menu = $MainMenu
var _game: Node


func _ready():
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

func _on_continue() -> void:
	_menu.visible = false
	_game.visible = true

func _on_stop() -> void:
	_menu.visible = true
	_menu.on_show()
	_game.queue_free()

func _on_pause() -> void:
	_menu.visible = true
	_menu.on_show()
	_game.visible = false
