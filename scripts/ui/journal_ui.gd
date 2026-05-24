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
	add_to_group("overlay_ui")
	visible = false
	close_btn.pressed.connect(_on_close)

func _input(event: InputEvent):
	if not event.is_action_pressed("journal"):
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

func _close():
	visible = false
	get_tree().paused = false

func _on_close():
	_close()

func _refresh():
	for child in entry_list.get_children():
		child.queue_free()
	
	session_count.text = I18n.t("journal_count") % GameManager.total_sessions_count
	
	var entries: Array = GameManager.therapy_journal
	if entries.is_empty():
		var label := Label.new()
		label.text = I18n.t("journal_empty")
		label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		entry_list.add_child(label)
		detail_text.text = ""
		strategies_label.text = ""
		return
	
	var pname: String = GameManager.PATIENT_NAMES.get(entry.get("patient_id", ""), entry.get("patient_id", ""))
		btn.text = "%s - #%d | %s | %d" % [
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
	strategies_label.text = "%s: %d" % [I18n.t("journal_strategies"), strategy_count]

func _show_detail(index: int):
	var entries: Array = GameManager.therapy_journal
	if index < 0 or index >= entries.size():
		return
	var entry: Dictionary = entries[index]
	
	var pname: String = GameManager.PATIENT_NAMES.get(entry.get("patient_id", ""), I18n.t("score_patient"))
	
	var text := "[b]%s - #%d[/b]\n" % [pname, entry.get("session", 0)]
	text += "%s: %s | %s: %d\n" % [I18n.t("score_grade"), entry.get("grade", "?"), I18n.t("score_total"), entry.get("score_total", 0)]
	text += "%s: %d\n" % [I18n.t("profile_trust"), entry.get("bond_after", 0)]
	
	var emotions: Dictionary = entry.get("emotions", {})
	if not emotions.is_empty():
		text += "\n[b]%s:[/b]\n" % I18n.t("score_emotion_state")
		var state_names := {"active": I18n.t("state_active"), "recovering": I18n.t("state_recovering"), "resilient": I18n.t("state_resilient")}
		for cat in emotions:
			text += "  %s: %s\n" % [cat, state_names.get(emotions[cat], emotions[cat])]
	
	detail_text.text = text
