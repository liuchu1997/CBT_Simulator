extends Control

signal tutorial_closed

@onready var panel: Panel = $CenterContainer/Panel
@onready var title_label: Label = $CenterContainer/Panel/MarginContainer/VBox/Title
@onready var content: VBoxContainer = $CenterContainer/Panel/MarginContainer/VBox/Content
@onready var continue_btn: Button = $CenterContainer/Panel/MarginContainer/VBox/ContinueBtn

var _step := 0
var _steps := [
	{
		"title": I18n.t("tutorial_welcome"),
		"lines": [
			I18n.t("tutorial_role"),
			"",
			I18n.t("tutorial_move"),
		]
	},
	{
		"title": I18n.t("tutorial_move"),
		"lines": [
			"WASD — " + I18n.t("tutorial_move"),
			"Space — " + I18n.t("tutorial_dialogue"),
			"I — " + I18n.t("profile_title"),
			"ESC — " + I18n.t("pause"),
		]
	},
	{
		"title": I18n.t("tutorial_dialogue"),
		"lines": [
			I18n.t("tutorial_dialogue"),
		]
	},
	{
		"title": I18n.t("tutorial_scoring"),
		"lines": [
			I18n.t("tutorial_scoring"),
		]
	},
	{
		"title": I18n.t("tutorial_task"),
		"lines": [
			I18n.t("tutorial_task"),
		]
	},
]

func _ready():
	_show_step()
	continue_btn.pressed.connect(_on_continue)
	continue_btn.grab_focus()

func _show_step():
	var data: Dictionary = _steps[_step]
	title_label.text = data["title"]
	
	for child in content.get_children():
		child.queue_free()
	
	await get_tree().process_frame
	
	for line in data["lines"]:
		var label := Label.new()
		label.text = line
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		content.add_child(label)
	
	if _step < _steps.size() - 1:
		continue_btn.text = I18n.t("continue_label") + " (%d/%d)" % [_step + 1, _steps.size()]
	else:
		continue_btn.text = I18n.t("tutorial_start")
	continue_btn.grab_focus()

func _on_continue():
	_step += 1
	if _step >= _steps.size():
		visible = false
		tutorial_closed.emit()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		_show_step()

func _input(event: InputEvent):
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		_on_continue()
