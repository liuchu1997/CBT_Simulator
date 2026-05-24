extends Control

@onready var task_label: RichTextLabel = $TaskLabel
@onready var interact_label: Label = $InteractLabel

var _current_task: String = ""
var _nearby_npc: String = ""

func _ready():
	visible = false
	_update_task()

func show_hud():
	visible = true

func set_task(text: String):
	_current_task = text
	_update_task()

func show_interact_hint(npc_name: String):
	interact_label.visible = true
	interact_label.text = I18n.t("space_talk_to") % npc_name
	_nearby_npc = npc_name

func hide_interact_hint():
	interact_label.visible = false
	_nearby_npc = ""

func _update_task():
	if _current_task != "":
		task_label.text = "[b]" + I18n.t("current_task_label") + "[/b] " + _current_task
		task_label.visible = true
	else:
		task_label.visible = false
