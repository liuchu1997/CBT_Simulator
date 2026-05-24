extends Control

@onready var background: ColorRect = $Background
@onready var grade_label: Label = $MarginContainer/Panel/VBoxContainer/Header/GradeRow/GradeLabel
@onready var total_label: Label = $MarginContainer/Panel/VBoxContainer/Header/GradeRow/TotalLabel
@onready var score_bars: VBoxContainer = $MarginContainer/Panel/VBoxContainer/ScoreSection/ScoreBars
@onready var good_list: VBoxContainer = $MarginContainer/Panel/VBoxContainer/FeedbackSection/GoodContainer
@onready var bad_list: VBoxContainer = $MarginContainer/Panel/VBoxContainer/FeedbackSection/BadContainer
@onready var feedback_label: RichTextLabel = $MarginContainer/Panel/VBoxContainer/FeedbackSection/FeedbackText
@onready var continue_btn: Button = $MarginContainer/Panel/VBoxContainer/ContinueBtn
@onready var session_label: Label = $MarginContainer/Panel/VBoxContainer/Header/SessionLabel
@onready var score_section_title: Label = $MarginContainer/Panel/VBoxContainer/ScoreSection/SectionTitle
@onready var feedback_section_title: Label = $MarginContainer/Panel/VBoxContainer/FeedbackSection/SectionTitle

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("overlay_ui")
	continue_btn.pressed.connect(_on_continue)
	visible = false
	_update_static_texts()
	I18n.language_changed.connect(func(_l): _update_static_texts())

func _update_static_texts():
	score_section_title.text = I18n.t("score_details")
	feedback_section_title.text = I18n.t("score_feedback")
	continue_btn.text = I18n.t("score_continue")

var _on_closed_callback: Callable = Callable()

func show_report(data: Dictionary, on_closed: Callable = Callable()):
	_on_closed_callback = on_closed
	visible = true
	get_tree().paused = true
	
	var patient_name: String = str(data.get("patient_name", I18n.t("score_patient")))
	var session_num: int = int(data.get("session_num", 1))
	
	session_label.text = "%s - %s #%d" % [patient_name, I18n.t("score_report_title"), session_num]
	var max_possible: int = data.get("max_possible", 50)
	grade_label.text = "%s: %s" % [I18n.t("score_grade"), data.get("grade", "C")]
	total_label.text = "%s: %d / %d" % [I18n.t("score_total"), data.get("total", 0), max_possible]
	
	_clear_children(score_bars)
	_clear_children(good_list)
	_clear_children(bad_list)
	
	var scores: Dictionary = data.get("scores", {})
	var category_names := {
		"empathy": I18n.t("dimension_empathy"),
		"active_listening": I18n.t("dimension_listening"),
		"socratic_questioning": I18n.t("dimension_socratic"),
		"cognitive_restructuring": I18n.t("dimension_cognitive"),
		"rapport": I18n.t("dimension_relationship"),
	}
	
	for cat in scores:
		var hbox := HBoxContainer.new()
		var name_label := Label.new()
		name_label.text = category_names.get(cat, cat)
		name_label.custom_minimum_size.x = 100
		name_label.add_theme_color_override("font_color", Color.WHITE)
		name_label.add_theme_font_size_override("font_size", 12)
		hbox.add_child(name_label)
		
		var bar := ProgressBar.new()
		bar.min_value = 0
		bar.max_value = ScoringSystem.MAX_PER_CATEGORY
		bar.value = scores[cat]
		bar.custom_minimum_size.x = 140
		bar.show_percentage = true
		hbox.add_child(bar)
		
		var val_label := Label.new()
		val_label.text = "%d/%d" % [scores[cat], ScoringSystem.MAX_PER_CATEGORY]
		val_label.add_theme_color_override("font_color", Color.WHITE)
		val_label.add_theme_font_size_override("font_size", 12)
		hbox.add_child(val_label)
		
		score_bars.add_child(hbox)
	
	for good in data.get("good_choices", []):
		var label := Label.new()
		label.text = "+ " + str(good)
		label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_font_size_override("font_size", 12)
		good_list.add_child(label)
	
	for bad in data.get("bad_choices", []):
		var label := Label.new()
		label.text = "- " + str(bad)
		label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.3))
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_font_size_override("font_size", 12)
		bad_list.add_child(label)
	
	feedback_label.text = str(data.get("feedback", ""))
	
	var emotion_state: String = str(data.get("emotion_state", ""))
	if emotion_state != "":
		_add_chapter_hint("[color=cyan]%s: %s | %s: %d%%[/color]" % [I18n.t("score_emotion_state"), emotion_state, I18n.t("score_alliance"), data.get("alliance", 0)])
	
	var effect_labels: Array = data.get("effectiveness_labels", [])
	if effect_labels.size() > 0:
		var eff_text := "[color=yellow]" + I18n.t("score_skill_effect") + ": " + ", ".join(effect_labels) + "[/color]"
		_add_chapter_hint(eff_text)
	
	var chapter_id: String = GameManager.current_chapter
	var chapter_def: Dictionary = GameManager.get_chapter_def(chapter_id)
	if not chapter_def.is_empty():
		var min_grade: String = chapter_def.get("min_grade", "D")
		var grade: String = data.get("grade", "D")
		var grade_order := ["D", "C", "B", "A", "S"]
		var grade_idx: int = grade_order.find(grade)
		var min_idx: int = grade_order.find(min_grade)
		
		if grade_idx >= min_idx:
			_add_chapter_hint("[color=green]" + I18n.t("score_chapter_pass") % min_grade + "[/color]")
		else:
			_add_chapter_hint("[color=red]" + I18n.t("score_chapter_fail") % [min_grade, grade] + "[/color]")
			_add_chapter_hint("[color=yellow]" + I18n.t("score_feedback") + "[/color]")
	
	continue_btn.grab_focus()

func _add_chapter_hint(text: String):
	var label := RichTextLabel.new()
	label.bbcode_enabled = true
	label.text = text
	label.fit_content = true
	label.scroll_following = false
	label.custom_minimum_size.y = 20
	label.add_theme_font_size_override("normal_font_size", 12)
	feedback_label.get_parent().add_child(label)

func _on_continue():
	visible = false
	get_tree().paused = false
	if _on_closed_callback.is_valid():
		_on_closed_callback.call()

func _input(event: InputEvent):
	if visible and event.is_action_pressed("interact"):
		_on_continue()

func _clear_children(node: Node):
	for child in node.get_children():
		child.queue_free()
