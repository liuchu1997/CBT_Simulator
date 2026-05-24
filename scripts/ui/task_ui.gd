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
	close_btn.text = I18n.t("close_t")
	GameManager.chapter_completed.connect(func(_c): _refresh_if_visible())
	GameManager.chapter_failed.connect(func(_c, _r): _refresh_if_visible())
	I18n.language_changed.connect(func(_l): close_btn.text = I18n.t("close_t"))

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
	var ch_title: String = cur_def.get("title", I18n.t("task_free_explore"))
	chapter_label.text = "%s  |  Lv.%d" % [ch_title, GameManager.therapist_level]
	
	_add_task_header(I18n.t("task_current"))
	if cur_def.is_empty() or cur_def.get("patient_id", "") == "":
		_add_task_row(I18n.t("task_explore"))
	else:
		var pid: String = cur_def.get("patient_id", "")
		var needed: int = cur_def.get("required_sessions", 3)
		var progress: int = GameManager.get_patient_progress(pid)
		var min_grade: String = cur_def.get("min_grade", "D")
		var pname: String = GameManager.PATIENT_NAMES.get(pid, pid)
		var skill_reqs_met := GameManager.meets_skill_requirements(cur_ch)
		
		if not skill_reqs_met:
			var missing: String = GameManager.get_missing_skills_text(cur_ch)
			_add_task_row(I18n.t("task_not_unlocked"))
			_add_task_row("%s: %s" % [I18n.t("skill_upgrade"), missing])
			_add_task_row("[%s]" % I18n.t("skill_tree_title"))
		elif progress >= needed:
			var status: String = GameManager.get_chapter_status_text()
			if status != "":
				_add_task_row(I18n.t("task_treatment_progress") % [progress, needed])
				_add_task_row("%s: %s" % [I18n.t("score_grade"), status])
			else:
				_add_task_row(I18n.t("task_completed"))
		else:
			_add_task_row(I18n.t("task_treatment_hint") % [pname, progress, needed])
			_add_task_row("%s: %s" % [I18n.t("task_chapter_info"), min_grade])
		
		_add_task_header(I18n.t("task_patient_status"))
		for test_pid in ["lin_xiaoyu", "zhang_hao", "wang_mei"]:
			if GameManager.is_patient_unlocked(test_pid):
				var test_name: String = GameManager.PATIENT_NAMES.get(test_pid, test_pid)
				var bond: int = GameManager.get_bond(test_pid)
				var bond_level: String = GameManager.get_bond_level(test_pid)
				var p: int = GameManager.get_patient_progress(test_pid)
				var state: String = GameManager.get_patient_emotion_summary(test_pid).strip_edges()
				if state == "":
					state = I18n.t("state_active")
				_add_patient_row(test_name, p, bond, bond_level, state)
			else:
				var locked_name: String = GameManager.PATIENT_NAMES.get(test_pid, "???")
				_add_patient_row(locked_name + " [%s]" % I18n.t("task_not_unlocked"), -1, 0, "", "")
	
	_add_task_header(I18n.t("task_treatment_tips"))
	var tips := _get_context_tips()
	for tip in tips:
		_add_tip_row(tip)
	
	hotkey_label.text = "[color=gray]%s[/color]" % I18n.t("task_hotkeys")

func _get_context_tips() -> Array:
	var tips: Array = []
	var cur_def: Dictionary = GameManager.get_chapter_def(GameManager.current_chapter)
	var pid: String = cur_def.get("patient_id", "")
	
	if pid == "lin_xiaoyu":
		tips.append(I18n.t("tip_lin"))
	elif pid == "zhang_hao":
		tips.append(I18n.t("tip_zhang"))
	elif pid == "wang_mei":
		tips.append(I18n.t("tip_wang"))
	
	if tips.is_empty():
		tips.append(I18n.t("task_treatment_tips"))
		tips.append(I18n.t("task_treatment_hint"))
	
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
		prog_label.text = "%d" % progress
		prog_label.custom_minimum_size.x = 40
		prog_label.add_theme_font_size_override("font_size", 12)
		prog_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
		hbox.add_child(prog_label)
		
		var bond_label := Label.new()
		bond_label.text = "%s%d" % [I18n.t("profile_trust"), bond]
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
