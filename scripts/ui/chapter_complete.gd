extends Control

@onready var bg: ColorRect = $Background
@onready var chapter_title: Label = $MarginContainer/Panel/VBox/Header/ChapterTitle
@onready var subtitle: Label = $MarginContainer/Panel/VBox/Header/Subtitle
@onready var stats: VBoxContainer = $MarginContainer/Panel/VBox/StatsContainer
@onready var unlock_label: RichTextLabel = $MarginContainer/Panel/VBox/UnlockSection/UnlockLabel
@onready var continue_btn: Button = $MarginContainer/Panel/VBox/ContinueBtn

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	continue_btn.pressed.connect(_on_continue)

func show_chapter_complete():
	visible = true
	get_tree().paused = true
	
	var chapter_id: String = ""
	for ch in GameManager.completed_chapters:
		chapter_id = ch
	var def: Dictionary = GameManager.get_chapter_def(chapter_id)
	var title: String = def.get("title", I18n.t("chapter_complete"))
	var pid: String = def.get("patient_id", "")
	
	chapter_title.text = title
	subtitle.text = I18n.t("chapter_complete")
	
	for child in stats.get_children():
		child.queue_free()
	
	var patient_names := {"lin_xiaoyu": I18n.t("patient_lin_xiaoyu"), "zhang_hao": I18n.t("patient_zhang_hao"), "wang_mei": I18n.t("patient_wang_mei")}
	var pname: String = patient_names.get(pid, pid)
	
	var sessions_done: int = GameManager.completed_sessions.get(pid, 0)
	_add_stat(I18n.t("journal_count") % sessions_done)
	_add_stat("%s: %d/100" % [I18n.t("profile_trust"), GameManager.get_bond(pid)])
	_add_stat("%s: +%d" % [I18n.t("skill_points_label"), sessions_done])
	_add_stat("%s: %d" % [I18n.t("score_total"), GameManager.total_score])
	
	var scores: Array = GameManager.patient_scores.get(pid, [])
	var grade_text := ""
	for s_data in scores:
		grade_text += "%s " % s_data.get("grade", "D")
	if grade_text != "":
		_add_stat("%s: %s" % [I18n.t("score_grade"), grade_text])
	
	var emotion_summary: String = GameManager.get_patient_emotion_summary(pid)
	if emotion_summary != I18n.t("state_active"):
		_add_stat("%s: %s" % [I18n.t("score_emotion_state"), emotion_summary])
	
	var next_chapter: String = def.get("unlock_next", "")
	if next_chapter != "":
		var next_def: Dictionary = GameManager.get_chapter_def(next_chapter)
		var next_title: String = next_def.get("title", "")
		var reqs: String = GameManager.get_missing_skills_text(next_chapter)
		var next_min: String = next_def.get("min_grade", "D")
		if reqs == "":
			unlock_label.text = "[color=green]%s: %s[/color]\n[color=white]%s: %s[/color]" % [I18n.t("chapter_unlock_next"), next_title, I18n.t("score_grade"), next_min]
		else:
			unlock_label.text = "[color=yellow]%s: %s[/color]\n[color=white]%s: %s\n%s:\n%s\n%s[/color]" % [I18n.t("chapter_unlock_next"), next_title, I18n.t("score_grade"), next_min, I18n.t("skill_upgrade"), reqs, I18n.t("task_hotkeys")]
	else:
		unlock_label.text = "[color=gold]%s[/color]\n[color=white]%s[/color]" % [I18n.t("congratulations"), I18n.t("chapter_complete")]
	
	continue_btn.grab_focus()

func _add_stat(text: String):
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))
	stats.add_child(label)

func _on_continue():
	visible = false
	get_tree().paused = false

func _input(event: InputEvent):
	if visible and event.is_action_pressed("interact"):
		_on_continue()
