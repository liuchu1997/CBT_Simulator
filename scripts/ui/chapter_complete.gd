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
	var title: String = def.get("title", "章节完成")
	var pid: String = def.get("patient_id", "")
	
	chapter_title.text = title
	subtitle.text = "章节完成！"
	
	for child in stats.get_children():
		child.queue_free()
	
	var patient_names := {"lin_xiaoyu": "林小雨", "zhang_hao": "张浩", "wang_mei": "王美"}
	var pname: String = patient_names.get(pid, pid)
	
	var sessions_done: int = GameManager.completed_sessions.get(pid, 0)
	_add_stat("治疗次数: %d" % sessions_done)
	_add_stat("信任值: %d/100" % GameManager.get_bond(pid))
	_add_stat("技能点: +%d" % sessions_done)
	_add_stat("总分: %d" % GameManager.total_score)
	
	var scores: Array = GameManager.patient_scores.get(pid, [])
	var grade_text := ""
	for s_data in scores:
		grade_text += "%s " % s_data.get("grade", "D")
	if grade_text != "":
		_add_stat("各次评级: %s" % grade_text)
	
	var emotion_summary: String = GameManager.get_patient_emotion_summary(pid)
	if emotion_summary != "初始评估中":
		_add_stat("情绪状态: %s" % emotion_summary)
	
	var next_chapter: String = def.get("unlock_next", "")
	if next_chapter != "":
		var next_def: Dictionary = GameManager.get_chapter_def(next_chapter)
		var next_title: String = next_def.get("title", "")
		var reqs: String = GameManager.get_missing_skills_text(next_chapter)
		var next_min: String = next_def.get("min_grade", "D")
		if reqs == "":
			unlock_label.text = "[color=green]下一章已解锁: %s[/color]\n[color=white]评级要求: %s级以上[/color]" % [next_title, next_min]
		else:
			unlock_label.text = "[color=yellow]下一章: %s[/color]\n[color=white]评级要求: %s级以上\n需要提升技能:\n%s\n按K键打开技能树[/color]" % [next_title, next_min, reqs]
	else:
		unlock_label.text = "[color=gold]恭喜！你已完成所有章节！[/color]\n[color=white]你已经成为了一名合格的CBT治疗师！[/color]"
	
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
