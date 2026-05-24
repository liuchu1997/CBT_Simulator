extends Control

@onready var bg: ColorRect = $Background
@onready var main_panel: Panel = $MarginContainer/TaskPanel
@onready var close_btn: Button = $MarginContainer/TaskPanel/VBox/Header/CloseBtn
@onready var chapter_label: Label = $MarginContainer/TaskPanel/VBox/Header/ChapterLabel
@onready var task_section: VBoxContainer = $MarginContainer/TaskPanel/VBox/Content/TaskSection
@onready var patient_section: VBoxContainer = $MarginContainer/TaskPanel/VBox/Content/PatientSection
@onready var tips_section: VBoxContainer = $MarginContainer/TaskPanel/VBox/Content/TipsSection
@onready var hotkey_label: RichTextLabel = $MarginContainer/TaskPanel/VBox/HotkeyBar

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("overlay_ui")
	visible = false
	close_btn.pressed.connect(_on_close)
	GameManager.chapter_completed.connect(func(_c): _refresh_if_visible())
	GameManager.chapter_failed.connect(func(_c, _r): _refresh_if_visible())

func _input(event: InputEvent):
	if not event.is_action_pressed("task_panel"):
		return
	if DialogueManager.is_active():
		return
	if _other_overlay_visible():
		return
	if visible:
		_close()
	else:
		_open()

func _other_overlay_visible() -> bool:
	var nodes := get_tree().get_nodes_in_group("overlay_ui")
	for n in nodes:
		if n != self and n is Control and n.visible:
			return true
	return false

func _open():
	visible = true
	get_tree().paused = true
	_refresh()
	close_btn.grab_focus()

func _close():
	visible = false
	get_tree().paused = false

func _on_close():
	_close()

func _refresh_if_visible():
	if visible:
		_refresh()

func _refresh():
	_clear_children(task_section)
	_clear_children(patient_section)
	_clear_children(tips_section)
	
	var cur_ch := GameManager.current_chapter
	var cur_def: Dictionary = GameManager.get_chapter_def(cur_ch)
	var ch_title: String = cur_def.get("title", "自由探索")
	chapter_label.text = "%s  |  治疗师 Lv.%d" % [ch_title, GameManager.therapist_level]
	
	_add_task_header("当前任务")
	if cur_def.is_empty() or cur_def.get("patient_id", "") == "":
		_add_task_row("探索诊室，与角色对话")
	else:
		var pid: String = cur_def.get("patient_id", "")
		var needed: int = cur_def.get("required_sessions", 3)
		var progress: int = GameManager.get_patient_progress(pid)
		var min_grade: String = cur_def.get("min_grade", "D")
		var pname: String = GameManager.PATIENT_NAMES.get(pid, pid)
		var skill_reqs_met := GameManager.meets_skill_requirements(cur_ch)
		
		if not skill_reqs_met:
			var missing: String = GameManager.get_missing_skills_text(cur_ch)
			_add_task_row("技能不足，需提升后解锁")
			_add_task_row("缺少: %s" % missing)
			_add_task_row("[按 K 键升级技能树]")
		elif progress >= needed:
			var status: String = GameManager.get_chapter_status_text()
			if status != "":
				_add_task_row("已完成 %d/%d 次治疗" % [progress, needed])
				_add_task_row("评级未达标: %s" % status)
			else:
				_add_task_row("章节完成!")
		else:
			_add_task_row("与 %s 对话进行治疗 (%d/%d)" % [pname, progress, needed])
			_add_task_row("章节要求: 最低 %s 级" % min_grade)
		
		_add_task_header("患者状态")
		for test_pid in ["lin_xiaoyu", "zhang_hao", "wang_mei"]:
			if GameManager.is_patient_unlocked(test_pid):
				var test_name: String = GameManager.PATIENT_NAMES.get(test_pid, test_pid)
				var bond: int = GameManager.get_bond(test_pid)
				var bond_level: String = GameManager.get_bond_level(test_pid)
				var p: int = GameManager.get_patient_progress(test_pid)
				var state: String = GameManager.get_patient_emotion_summary(test_pid).strip_edges()
				if state == "":
					state = "初始评估中"
				_add_patient_row(test_name, p, bond, bond_level, state)
			else:
				var locked_name: String = GameManager.PATIENT_NAMES.get(test_pid, "???")
				_add_patient_row(locked_name + " [未解锁]", -1, 0, "", "")
	
	_add_task_header("治疗提示")
	var tips := _get_context_tips()
	for tip in tips:
		_add_tip_row(tip)
	
	hotkey_label.text = "[color=gray]T 任务 | K 技能树 | J 日志 | I 患者档案 | ESC 暂停[/color]"

func _get_context_tips() -> Array:
	var tips: Array = []
	var cur_def: Dictionary = GameManager.get_chapter_def(GameManager.current_chapter)
	var pid: String = cur_def.get("patient_id", "")
	
	if pid == "lin_xiaoyu":
		tips.append("林小雨有抑郁倾向，容易出现非黑即白思维")
		tips.append("先用共情和倾听建立信任，再引导检视思维")
		tips.append("防御时用反映/确认技巧，反思时用认知重构")
	elif pid == "zhang_hao":
		tips.append("张浩的问题是灾难化思维，总往最坏处想")
		tips.append("用苏格拉底提问检视担忧的现实基础")
		tips.append("不要说'想太多没用'——他不被理解会更焦虑")
	elif pid == "wang_mei":
		tips.append("王美倾向个人化，什么错都怪自己")
		tips.append("双标准技术很有效：'如果是同事遇到呢？'")
		tips.append("不要简单安慰'别怪自己'——要引导她自己发现")
	
	if tips.is_empty():
		tips.append("通用技巧: 先共情倾听，不要急着给建议")
		tips.append("用提问引导患者自己发现问题")
	
	return tips

func _add_task_header(text: String):
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 15)
	label.add_theme_color_override("font_color", Color(1, 0.9, 0.4))
	label.custom_minimum_size.y = 24
	task_section.add_child(label)

func _add_task_row(text: String):
	var label := Label.new()
	label.text = "  " + text
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0, 0.9))
	task_section.add_child(label)

func _add_patient_row(name: String, progress: int, bond: int, bond_level: String, state: String):
	var hbox := HBoxContainer.new()
	
	var name_label := Label.new()
	name_label.text = name
	name_label.custom_minimum_size.x = 120
	name_label.add_theme_font_size_override("font_size", 13)
	name_label.add_theme_color_override("font_color", Color(0.7, 0.9, 1.0))
	hbox.add_child(name_label)
	
	if progress >= 0:
		var prog_label := Label.new()
		prog_label.text = "%d次" % progress
		prog_label.custom_minimum_size.x = 40
		prog_label.add_theme_font_size_override("font_size", 12)
		prog_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
		hbox.add_child(prog_label)
		
		var bond_label := Label.new()
		bond_label.text = "信任%d" % bond
		bond_label.custom_minimum_size.x = 60
		bond_label.add_theme_font_size_override("font_size", 12)
		var bond_color := Color(0.4, 1.0, 0.4) if bond >= 60 else Color(1.0, 0.8, 0.4) if bond >= 30 else Color(1.0, 0.5, 0.4)
		bond_label.add_theme_color_override("font_color", bond_color)
		hbox.add_child(bond_label)
		
		var state_label := Label.new()
		state_label.text = state
		state_label.add_theme_font_size_override("font_size", 11)
		state_label.add_theme_color_override("font_color", Color(0.6, 0.7, 0.8))
		hbox.add_child(state_label)
	
	patient_section.add_child(hbox)

func _add_tip_row(text: String):
	var label := Label.new()
	label.text = "· " + text
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color(0.75, 0.85, 0.7))
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tips_section.add_child(label)

func _clear_children(node: Node):
	for child in node.get_children():
		child.queue_free()
