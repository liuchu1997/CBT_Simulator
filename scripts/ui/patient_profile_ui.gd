extends Control

signal closed

@onready var name_label: Label = $CenterContainer/Panel/MarginContainer/VBoxContainer/Header/NameLabel
@onready var diag_label: Label = $CenterContainer/Panel/MarginContainer/VBoxContainer/Header/DiagLabel
@onready var emotion_container: VBoxContainer = $CenterContainer/Panel/MarginContainer/VBoxContainer/EmotionSection/EmotionBars
@onready var distortions_label: RichTextLabel = $CenterContainer/Panel/MarginContainer/VBoxContainer/DistortionSection/DistortionsLabel
@onready var session_label: RichTextLabel = $CenterContainer/Panel/MarginContainer/VBoxContainer/SessionSection/SessionLabel
@onready var close_btn: Button = $CenterContainer/Panel/MarginContainer/VBoxContainer/CloseBtn

var _current_patient: Node = null

func _ready():
	visible = false
	close_btn.pressed.connect(func():
		visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		closed.emit()
	)

func toggle_patient_profile():
	if visible:
		visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		return
	
	var patient_nodes := get_tree().get_nodes_in_group("patient")
	if patient_nodes.is_empty():
		return
	
	_current_patient = patient_nodes[0]
	if _current_patient:
		show_profile(_current_patient)

func show_profile(patient: Node):
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	var p_id: String = patient.get("patient_id") if patient.get("patient_id") else ""
	var p_name: String = patient.get("npc_name") if patient.get("npc_name") else "未知"
	
	name_label.text = "患者: %s" % p_name
	
	var diagnoses := {
		"lin_xiaoyu": "中度抑郁",
		"zhang_hao": "广泛性焦虑",
		"wang_mei": "社交焦虑",
	}
	diag_label.text = "诊断: %s" % diagnoses.get(p_id, "评估中")
	
	for child in emotion_container.get_children():
		child.queue_free()
	
	var emotion_names := {
		"depression": "抑郁",
		"anxiety": "焦虑",
		"anger": "愤怒",
		"hope": "希望",
		"trust": "信任度",
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
		distortions_label.text = "、".join(dist)
	else:
		distortions_label.text = "暂无"
	
	var progress := GameManager.get_patient_progress(p_id)
	var max_s: int = patient.get("max_sessions") if patient.get("max_sessions") else 5
	session_label.text = "已完成 %d / %d 次会话" % [progress, max_s]
	close_btn.grab_focus()

func _input(event: InputEvent):
	if visible and event.is_action_pressed("ui_cancel"):
		visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
