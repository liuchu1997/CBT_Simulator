extends Control

@onready var bg: ColorRect = $Background
@onready var main_panel: Panel = $MarginContainer/JournalPanel
@onready var close_btn: Button = $MarginContainer/JournalPanel/VBox/Header/CloseBtn
@onready var session_count: Label = $MarginContainer/JournalPanel/VBox/Header/SessionCount
@onready var entry_list: VBoxContainer = $MarginContainer/JournalPanel/VBox/Body/EntryList
@onready var detail_panel: Panel = $MarginContainer/JournalPanel/VBox/Body/DetailPanel
@onready var detail_text: RichTextLabel = $MarginContainer/JournalPanel/VBox/Body/DetailPanel/MarginContainer/DetailText
@onready var strategies_label: Label = $MarginContainer/JournalPanel/VBox/Body/StrategiesLabel

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	close_btn.pressed.connect(_on_close)

func _input(event: InputEvent):
	if not event.is_action_pressed("journal"):
		return
	if DialogueManager.is_active():
		return
	if visible:
		_close()
	else:
		_open()

func _open():
	visible = true
	get_tree().paused = true
	_refresh()

func _close():
	visible = false
	get_tree().paused = false

func _on_close():
	_close()

func _refresh():
	for child in entry_list.get_children():
		child.queue_free()
	
	session_count.text = "治疗次数: %d" % GameManager.total_sessions_count
	
	var entries: Array = GameManager.therapy_journal
	if entries.is_empty():
		var label := Label.new()
		label.text = "暂无记录。开始你的第一次治疗吧！"
		label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		entry_list.add_child(label)
		detail_text.text = ""
		strategies_label.text = ""
		return
	
	var patient_names := {"lin_xiaoyu": "林小雨", "zhang_hao": "张浩", "wang_mei": "王美"}
	
	for i in range(entries.size()):
		var entry: Dictionary = entries[entries.size() - 1 - i]
		var btn := Button.new()
		var pname: String = patient_names.get(entry.get("patient_id", ""), entry.get("patient_id", ""))
		btn.text = "%s - 第%d次 | %s级 | %d分" % [
			pname,
			entry.get("session", 0),
			entry.get("grade", "?"),
			entry.get("score_total", 0),
		]
		btn.add_theme_font_size_override("font_size", 12)
		btn.custom_minimum_size = Vector2(0, 26)
		var idx: int = entries.size() - 1 - i
		btn.pressed.connect(func(): _show_detail(idx))
		entry_list.add_child(btn)
	
	var strategy_count: int = GameManager.learned_strategies.size()
	strategies_label.text = "已学策略: %d个" % strategy_count

func _show_detail(index: int):
	var entries: Array = GameManager.therapy_journal
	if index < 0 or index >= entries.size():
		return
	var entry: Dictionary = entries[index]
	
	var patient_names := {"lin_xiaoyu": "林小雨", "zhang_hao": "张浩", "wang_mei": "王美"}
	var pname: String = patient_names.get(entry.get("patient_id", ""), "未知")
	
	var text := "[b]%s - 第%d次治疗[/b]\n" % [pname, entry.get("session", 0)]
	text += "评级: %s | 得分: %d\n" % [entry.get("grade", "?"), entry.get("score_total", 0)]
	text += "信任值: %d\n" % entry.get("bond_after", 0)
	
	var emotions: Dictionary = entry.get("emotions", {})
	if not emotions.is_empty():
		text += "\n[b]情绪状态:[/b]\n"
		var state_names := {"active": "活跃", "recovering": "恢复中", "resilient": "有韧性"}
		for cat in emotions:
			text += "  %s: %s\n" % [cat, state_names.get(emotions[cat], emotions[cat])]
	
	detail_text.text = text
