extends Control

func _ready() -> void:
	Game.paused.connect(func(): visible = false)
	Game.continued.connect(func(): visible = true)

func on_devils_update(count: int) -> void:
	%DevilsCount.text = str(count)
