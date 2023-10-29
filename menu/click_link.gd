extends Label

var _saved_color

func _ready() -> void:
	if text.contains("http"):
		if not label_settings:
			label_settings = LabelSettings.new()
		gui_input.connect(_on_gui_input)
		mouse_entered.connect(_on_mouse_entered)
		mouse_exited.connect(_on_mouse_exited)


func _on_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton) and event.pressed and (event.button_index == MouseButton.MOUSE_BUTTON_LEFT):
		var idx := text.find("http")
		if idx >= 0:
			OS.shell_open(text.substr(idx))
		get_viewport().set_input_as_handled()


func _on_mouse_entered() -> void:
	_saved_color = label_settings.font_color
	label_settings.font_color = Color.BLUE


func _on_mouse_exited() -> void:
	label_settings.font_color = _saved_color
