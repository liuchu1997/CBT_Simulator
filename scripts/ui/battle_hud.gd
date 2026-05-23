extends Control

@onready var _alliance_bar: ProgressBar = $Panel/MarginContainer/VBoxContainer/AllianceRow/AllianceBar
@onready var _alliance_label: Label = $Panel/MarginContainer/VBoxContainer/AllianceRow/AllianceLabel
@onready var _state_label: Label = $Panel/MarginContainer/VBoxContainer/StateRow/StateValue
@onready var _patient_name: Label = $Panel/MarginContainer/VBoxContainer/PatientName
@onready var _stats_container: VBoxContainer = $Panel/MarginContainer/VBoxContainer/StatsContainer
@onready var _effect_label: Label = $Panel/MarginContainer/VBoxContainer/EffectLabel
@onready var _schema_label: Label = $Panel/MarginContainer/VBoxContainer/SchemaLabel
@onready var _turn_label: Label = $Panel/MarginContainer/VBoxContainer/TurnRow/TurnValue

var _current_patient_id: String = ""
var _stat_bars: Dictionary = {}
var _effect_tween: Tween = null
var _schema_tween: Tween = null

func _ready():
	visible = false
	_patient_name.add_theme_font_size_override("font_size", 13)
	_patient_name.add_theme_color_override("font_color", Color(1, 0.95, 0.6))
	var at: Label = $Panel/MarginContainer/VBoxContainer/AllianceRow/AllianceTitle
	at.add_theme_font_size_override("font_size", 11)
	at.add_theme_color_override("font_color", Color(0.3, 1, 0.5))
	_alliance_label.add_theme_font_size_override("font_size", 10)
	_alliance_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
	_state_label.add_theme_font_size_override("font_size", 11)
	_state_label.add_theme_color_override("font_color", Color(0.9, 0.5, 0.3))
	var st: Label = $Panel/MarginContainer/VBoxContainer/StateRow/StateTitle
	st.add_theme_font_size_override("font_size", 11)
	st.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
	_turn_label.add_theme_font_size_override("font_size", 11)
	_turn_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
	var tt: Label = $Panel/MarginContainer/VBoxContainer/TurnRow/TurnTitle
	tt.add_theme_font_size_override("font_size", 11)
	tt.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
	_effect_label.add_theme_font_size_override("font_size", 12)
	_schema_label.add_theme_font_size_override("font_size", 11)
	
	BattleEngine.alliance_changed.connect(_on_alliance_changed)
	BattleEngine.state_changed.connect(_on_state_changed)
	BattleEngine.battle_effect.connect(_on_battle_effect)
	BattleEngine.schema_discovered.connect(_on_schema_discovered)
	GameManager.session_started.connect(_on_session_started)
	GameManager.session_ended.connect(_on_session_ended)

func _on_session_started(pid: String, _snum: int):
	_current_patient_id = pid
	visible = true
	_patient_name.text = _get_patient_display_name(pid)
	_effect_label.visible = false
	_schema_label.visible = false
	_build_stat_bars()
	_update_all()

func _on_session_ended(_pid: String, _snum: int):
	_current_patient_id = ""
	visible = false

func _update_all():
	if _current_patient_id == "":
		return
	var data: Dictionary = BattleEngine.get_patient_data(_current_patient_id)
	if data.is_empty():
		return
	
	_alliance_bar.value = BattleEngine.get_alliance(_current_patient_id)
	_alliance_label.text = "%d/100" % BattleEngine.get_alliance(_current_patient_id)
	_state_label.text = BattleEngine.get_state_name(_current_patient_id)
	_state_label.add_theme_color_override("font_color", _state_color(BattleEngine.get_state(_current_patient_id)))
	_turn_label.text = str(BattleEngine.get_turn_count(_current_patient_id))
	
	var stat_keys := ["anxiety", "depression", "defensiveness", "insight", "avoidance", "hope"]
	for key in stat_keys:
		if _stat_bars.has(key):
			var val: int = data.get(key, 0)
			_stat_bars[key]["bar"].value = val
			_stat_bars[key]["label"].text = "%d" % val

func _build_stat_bars():
	for child in _stats_container.get_children():
		child.queue_free()
	_stat_bars.clear()
	
	var stat_config := [
		{"key": "anxiety", "name": "焦虑", "color": Color(1.0, 0.5, 0.2)},
		{"key": "depression", "name": "抑郁", "color": Color(0.4, 0.4, 0.8)},
		{"key": "defensiveness", "name": "防御", "color": Color(0.8, 0.3, 0.3)},
		{"key": "insight", "name": "洞察", "color": Color(0.3, 0.9, 0.5)},
		{"key": "avoidance", "name": "回避", "color": Color(0.7, 0.7, 0.3)},
		{"key": "hope", "name": "希望", "color": Color(1.0, 0.9, 0.3)},
	]
	
	for cfg in stat_config:
		var hbox := HBoxContainer.new()
		var name_l := Label.new()
		name_l.text = cfg["name"]
		name_l.custom_minimum_size.x = 36
		name_l.add_theme_font_size_override("font_size", 10)
		name_l.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
		hbox.add_child(name_l)
		
		var bar := ProgressBar.new()
		bar.min_value = 0
		bar.max_value = 100
		bar.value = 0
		bar.custom_minimum_size = Vector2(80, 12)
		bar.show_percentage = false
		bar.modulate = cfg["color"]
		hbox.add_child(bar)
		
		var val_l := Label.new()
		val_l.text = "0"
		val_l.custom_minimum_size.x = 24
		val_l.add_theme_font_size_override("font_size", 10)
		val_l.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
		hbox.add_child(val_l)
		
		_stats_container.add_child(hbox)
		_stat_bars[cfg["key"]] = {"bar": bar, "label": val_l}

func _on_alliance_changed(pid: String, _new_val: int):
	if pid == _current_patient_id:
		_update_all()

func _on_state_changed(pid: String, _new_state: String):
	if pid == _current_patient_id:
		_update_all()

func _on_battle_effect(pid: String, _skill: String, eff_label: String, delta_text: String):
	if pid != _current_patient_id:
		return
	_effect_label.text = "%s (alliance %s)" % [eff_label, delta_text]
	_effect_label.add_theme_color_override("font_color", _eff_color(eff_label))
	_effect_label.visible = true
	if _effect_tween:
		_effect_tween.kill()
	_effect_tween = create_tween()
	_effect_tween.tween_interval(2.5)
	_effect_tween.tween_callback(func(): _effect_label.visible = false)
	_update_all()

func _on_schema_discovered(pid: String, schema: String):
	if pid != _current_patient_id:
		return
	_schema_label.text = "[发现隐藏信念] %s" % schema
	_schema_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	_schema_label.visible = true
	if _schema_tween:
		_schema_tween.kill()
	_schema_tween = create_tween()
	_schema_tween.tween_interval(4.0)
	_schema_tween.tween_callback(func(): _schema_label.visible = false)

func _state_color(state: int) -> Color:
	match state:
		0: return Color(0.8, 0.3, 0.3)
		1: return Color(0.9, 0.7, 0.3)
		2: return Color(0.3, 0.8, 0.5)
		3: return Color(1.0, 0.4, 0.4)
		4: return Color(0.6, 0.2, 0.2)
		5: return Color(0.4, 0.6, 0.9)
		6: return Color(1.0, 0.9, 0.3)
		_: return Color.WHITE

func _eff_color(label: String) -> Color:
	if "拔群" in label: return Color(0.2, 1.0, 0.4)
	if "很有效" in label: return Color(0.4, 0.9, 0.5)
	if "一般" in label: return Color(0.8, 0.8, 0.8)
	if "不佳" in label: return Color(1.0, 0.5, 0.2)
	if "无效" in label: return Color(1.0, 0.2, 0.2)
	return Color.WHITE

func _get_patient_display_name(pid: String) -> String:
	return GameManager.PATIENT_NAMES.get(pid, pid)
