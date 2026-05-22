extends Control

signal tutorial_closed

@onready var panel: Panel = $CenterContainer/Panel
@onready var title_label: Label = $CenterContainer/Panel/MarginContainer/VBox/Title
@onready var content: VBoxContainer = $CenterContainer/Panel/MarginContainer/VBox/Content
@onready var continue_btn: Button = $CenterContainer/Panel/MarginContainer/VBox/ContinueBtn

var _step := 0
var _steps := [
	{
		"title": "欢迎来到 CBT 心理治疗模拟器",
		"lines": [
			"你是一名心理咨询师。",
			"你的工作是倾听患者、运用认知行为疗法(CBT)技术帮助他们。",
			"",
			"让我们先了解一下基本操作。",
		]
	},
	{
		"title": "基本操作",
		"lines": [
			"WASD / 方向键 — 移动角色",
			"空格键 — 与面前的人对话 / 推进对话",
			"I 键 — 查看患者档案",
			"ESC — 暂停菜单",
		]
	},
	{
		"title": "如何对话",
		"lines": [
			"走到患者面前，按 [空格] 开始对话。",
			"对话中会出现多个选项，点击你的回应。",
			"不同的回应对应不同的 CBT 技术，会影响评分。",
		]
	},
	{
		"title": "评分系统",
		"lines": [
			"每次治疗结束后会给出评分报告。",
			"评分维度：共情 / 倾听 / 苏格拉底提问 / 认知重构 / 治疗关系",
			"获得高评价需要运用专业的 CBT 技术。",
		]
	},
	{
		"title": "当前任务",
		"lines": [
			"候诊大厅里有前台小李，可以先和她聊聊。",
			"楼上诊室有患者林小雨（抑郁症），去和她对话吧。",
			"走近她，按空格键开始第一次治疗。",
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
		continue_btn.text = "下一步 (%d/%d)" % [_step + 1, _steps.size()]
	else:
		continue_btn.text = "开始游戏"
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
