extends Control

signal closed

@onready var name_label: Label = $CenterContainer/Panel/MarginContainer/VBoxContainer/Header/NameLabel
@onready var diag_label: Label = $CenterContainer/Panel/MarginContainer/VBoxContainer/Header/DiagLabel
@onready var emotion_container: VBoxContainer = $CenterContainer/Panel/MarginContainer/VBoxContainer/EmotionSection/EmotionBars
@onready var distortions_label: RichTextLabel = $CenterContainer/Panel/MarginContainer/VBoxContainer/DistortionSection/DistortionsLabel
@onready var session_label: RichTextLabel = $CenterContainer/Panel/MarginContainer/VBoxContainer/SessionSection/SessionLabel
@onready var close_btn: Button = $CenterContainer/Panel/MarginContainer/VBoxContainer/CloseBtn

var _current_patient: Node = null
var _patient_index: int = 0

func _ready():
	add_to_group("ui")
	add_to_group("overlay_ui")
	visible = false
	close_btn.pressed.connect(func():
		visible = false
		closed.emit()
	)

func toggle_patient_profile():
	if visible:
		visible = false
		return
	
	var patient_nodes := get_tree().get_nodes_in_group("patient")
	if patient_nodes.is_empty():
		return
	
	_patient_index = (_patient_index + 1) % patient_nodes.size()
	_current_patient = patient_nodes[_patient_index]
	if _current_patient:
		show_profile(_current_patient)

func show_profile(patient: Node):
	visible = true
	
	var p_id: String = patient.get("patient_id") if patient.get("patient_id") else ""
	var p_name: String = patient.get("npc_name") if patient.get("npc_name") else I18n.t("profile_name")
	
	name_label.text = "%s: %s" % [I18n.t("score_patient"), p_name]
	
	var diagnoses := {
		"lin_xiaoyu": I18n.t("diagnosis_depression"),
		"zhang_hao": I18n.t("diagnosis_gad"),
		"wang_mei": I18n.t("diagnosis_social_anxiety"),
	}
	diag_label.text = "%s: %s" % [I18n.t("profile_diagnosis"), diagnoses.get(p_id, "-")]
	
	for child in emotion_container.get_children():
		child.queue_free()
	
	var emotion_names := {
		"depression": I18n.t("emotion_depression"),
		"anxiety": I18n.t("emotion_anxiety"),
		"anger": I18n.t("emotion_anger"),
		"hope": I18n.t("emotion_hope"),
		"trust": I18n.t("profile_trust"),
	}
	
	if patient.get("emotion"):
		var emotion: Dictionary = patient.emotion
		for key in emotion:
			var hbox := HBoxContainer.new()
			var label := Label.new()
			label.text = emotion_names.get(key, key)
			label.custom_minimum_size.x = 60
			hbox.add_child(label)
			
			var bar := ProgressBar.new()
			bar.min_value = 0
			bar.max_value = 100
			bar.value = emotion[key]
			bar.custom_minimum_size.x = 150
			hbox.add_child(bar)
			
			var val := Label.new()
			val.text = str(int(emotion[key]))
			val.custom_minimum_size.x = 30
			hbox.add_child(val)
			
			emotion_container.add_child(hbox)
	
	if patient.get("cognitive_distortions"):
		var dist: Array = patient.cognitive_distortions
		distortions_label.text = ", ".join(dist)
	else:
		distortions_label.text = I18n.t("journal_empty")
	
	var progress := GameManager.get_patient_progress(p_id)
	var max_s: int = patient.get("max_sessions") if patient.get("max_sessions") else 5
	session_label.text = I18n.t("profile_records") % [progress, max_s]
	close_btn.grab_focus()

func _input(event: InputEvent):
	if visible and event.is_action_pressed("ui_cancel"):
		visible = false
