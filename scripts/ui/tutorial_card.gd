extends Control

@onready var card_panel: Panel = $CardPanel
@onready var title_label: Label = $CardPanel/MarginContainer/VBox/TitleLabel
@onready var text_label: RichTextLabel = $CardPanel/MarginContainer/VBox/TextLabel
@onready var ok_btn: Button = $CardPanel/MarginContainer/VBox/OkBtn

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	ok_btn.pressed.connect(_on_ok)
	CbtTutorial.tutorial_shown.connect(_on_tutorial)

func _on_tutorial(_id: String, title: String, text: String):
	title_label.text = title
	text_label.text = text
	visible = true
	ok_btn.grab_focus()

func _on_ok():
	visible = false
	CbtTutorial.dismiss_current()

func _input(event: InputEvent):
	if visible and event.is_action_pressed("interact"):
		_on_ok()
