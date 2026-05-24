extends Control

var _move_dir: Vector2 = Vector2.ZERO
var _buttons: Dictionary = {}

func _ready():
	add_to_group("touch_controls")
	_build_dpad()
	_build_action_buttons()
	_detect_and_show()

func _detect_and_show():
	var is_mobile := OS.has_feature("web") or OS.has_feature("android") or OS.has_feature("ios")
	visible = is_mobile
	if DisplayServer.screen_get_size().x > 0:
		var touch_count := Input.get_connected_joypads().size()
		if touch_count > 0:
			visible = true

func get_move_direction() -> Vector2:
	return _move_dir

func is_action_pressed(action: String) -> bool:
	return _buttons.get(action, false)

func _build_dpad():
	var dpad := Panel.new()
	dpad.name = "DPad"
	dpad.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	dpad.offset_left = 10
	dpad.offset_top = -160
	dpad.offset_right = 150
	dpad.offset_bottom = -10
	dpad.self_modulate = Color(1, 1, 1, 0.4)
	add_child(dpad)
	
	var btn_size := Vector2(40, 40)
	var center := Vector2(70, 75)
	
	_up("Up", center + Vector2(0, -45), btn_size, dpad)
	_up("Down", center + Vector2(0, 45), btn_size, dpad)
	_up("Left", center + Vector2(-45, 0), btn_size, dpad)
	_up("Right", center + Vector2(45, 0), btn_size, dpad)

func _up(name: String, pos: Vector2, size: Vector2, parent: Control):
	var btn := Button.new()
	btn.name = name
	btn.position = pos - size / 2
	btn.size = size
	btn.text = _arrow_text(name)
	btn.add_theme_font_size_override("font_size", 20)
	btn.add_theme_color_override("font_color", Color(1, 1, 1, 0.9))
	btn.add_theme_color_override("font_hover_color", Color(1, 0.95, 0.4))
	btn.flat = true
	parent.add_child(btn)
	
	var action_name: String = "move_" + name.to_lower()
	btn.button_down.connect(func(): _buttons[action_name] = true)
	btn.button_up.connect(func(): _buttons[action_name] = false)

func _arrow_text(dir: String) -> String:
	match dir:
		"Up": return "^"
		"Down": return "v"
		"Left": return "<"
		"Right": return ">"
		_: return "?"

func _build_action_buttons():
	var actions := Panel.new()
	actions.name = "Actions"
	actions.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	actions.offset_left = -170
	actions.offset_top = -160
	actions.offset_right = -10
	actions.offset_bottom = -10
	actions.self_modulate = Color(1, 1, 1, 0.4)
	add_child(actions)
	
	_action_btn("A", Vector2(90, 30), Vector2(50, 50), "interact", actions)
	_action_btn("B", Vector2(30, 70), Vector2(50, 50), "ui_cancel", actions)
	_action_btn("K", Vector2(90, 110), Vector2(50, 50), "skill_tree", actions)
	_action_btn("J", Vector2(30, 110), Vector2(50, 50), "journal", actions)
	_action_btn("I", Vector2(150, 30), Vector2(50, 50), "profile", actions)
	_action_btn("T", Vector2(150, 110), Vector2(50, 50), "task_panel", actions)

func _action_btn(label: String, pos: Vector2, size: Vector2, action: String, parent: Control):
	var btn := Button.new()
	btn.name = "Btn" + label
	btn.position = pos
	btn.size = size
	btn.text = label
	btn.add_theme_font_size_override("font_size", 18)
	btn.add_theme_color_override("font_color", Color(1, 1, 1, 0.9))
	btn.add_theme_color_override("font_hover_color", Color(1, 0.95, 0.4))
	btn.flat = true
	parent.add_child(btn)
	
	btn.button_down.connect(func():
		_buttons[action] = true
		var ev := InputEventAction.new()
		ev.action = action
		ev.pressed = true
		Input.parse_input_event(ev)
	)
	btn.button_up.connect(func():
		_buttons[action] = false
		var ev := InputEventAction.new()
		ev.action = action
		ev.pressed = false
		Input.parse_input_event(ev)
	)

func _process(_delta: float):
	_move_dir = Vector2.ZERO
	if _buttons.get("move_up", false): _move_dir.y -= 1
	if _buttons.get("move_down", false): _move_dir.y += 1
	if _buttons.get("move_left", false): _move_dir.x -= 1
	if _buttons.get("move_right", false): _move_dir.x += 1
