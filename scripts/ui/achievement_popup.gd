extends Control

@onready var popup: Panel = $PopupPanel
@onready var icon_label: Label = $PopupPanel/MarginContainer/HBox/IconLabel
@onready var title_label: Label = $PopupPanel/MarginContainer/HBox/VBox/TitleLabel
@onready var desc_label: Label = $PopupPanel/MarginContainer/HBox/VBox/DescLabel

var _queue: Array[Dictionary] = []
var _tween: Tween = null

var _achievement_defs := {
	"first_session": {"title": "初次问诊", "desc": "完成第一次治疗", "icon": "*"},
	"five_sessions": {"title": "经验丰富", "desc": "完成5次治疗", "icon": "**"},
	"perfect_score": {"title": "完美治疗", "desc": "获得S级评分", "icon": "***"},
	"cognitive_master": {"title": "认知大师", "desc": "认知重构满级", "icon": "***"},
	"behavioral_master": {"title": "行为专家", "desc": "行为激活满级", "icon": "***"},
	"empathic_master": {"title": "共情之师", "desc": "共情倾听满级", "icon": "***"},
	"all_skills_max": {"title": "全能治疗师", "desc": "所有技能满级", "icon": "****"},
	"trust_50": {"title": "获得信任", "desc": "患者信任达到50", "icon": "*"},
	"trust_80": {"title": "深度联结", "desc": "患者信任达到80", "icon": "**"},
	"first_resilient": {"title": "一线希望", "desc": "帮助患者达到恢复状态", "icon": "**"},
	"breakthrough": {"title": "突破", "desc": "患者恢复且信任>60", "icon": "***"},
	"unlock_zhang": {"title": "新患者", "desc": "解锁张浩", "icon": "*"},
	"unlock_wang_mei": {"title": "更多患者", "desc": "解锁王美", "icon": "**"},
}

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	GameManager.achievement_unlocked.connect(_on_achievement)

func _on_achievement(achievement_id: String):
	var def: Dictionary = _achievement_defs.get(achievement_id, {})
	if def.is_empty():
		def = {"title": achievement_id, "desc": "成就解锁！", "icon": "*"}
	_queue.append(def)
	if not visible:
		_show_next()

func _show_next():
	if _queue.is_empty():
		visible = false
		return
	var def: Dictionary = _queue.pop_front()
	icon_label.text = def.get("icon", "*")
	title_label.text = "成就解锁: %s" % def.get("title", "")
	desc_label.text = def.get("desc", "")
	visible = true
	
	if _tween:
		_tween.kill()
	modulate.a = 0.0
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, 0.3)
	_tween.tween_interval(2.5)
	_tween.tween_property(self, "modulate:a", 0.0, 0.5)
	_tween.tween_callback(_show_next)
