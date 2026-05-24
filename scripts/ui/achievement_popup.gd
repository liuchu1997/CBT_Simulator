extends Control

@onready var popup: Panel = $PopupPanel
@onready var icon_label: Label = $PopupPanel/MarginContainer/HBox/IconLabel
@onready var title_label: Label = $PopupPanel/MarginContainer/HBox/VBox/TitleLabel
@onready var desc_label: Label = $PopupPanel/MarginContainer/HBox/VBox/DescLabel

var _queue: Array[Dictionary] = []
var _tween: Tween = null

var _achievement_defs := {
	"first_session": {"title": I18n.t("ach_first_session"), "desc": I18n.t("ach_first_session_d"), "icon": "*"},
	"five_sessions": {"title": I18n.t("ach_five_sessions"), "desc": I18n.t("ach_five_sessions_d"), "icon": "**"},
	"perfect_score": {"title": I18n.t("ach_perfect"), "desc": I18n.t("ach_perfect_d"), "icon": "***"},
	"cognitive_master": {"title": I18n.t("ach_cognitive"), "desc": I18n.t("ach_cognitive_d"), "icon": "***"},
	"behavioral_master": {"title": I18n.t("ach_behavioral"), "desc": I18n.t("ach_behavioral_d"), "icon": "***"},
	"empathic_master": {"title": I18n.t("ach_empathic"), "desc": I18n.t("ach_empathic_d"), "icon": "***"},
	"all_skills_max": {"title": I18n.t("ach_all_master"), "desc": I18n.t("ach_all_master_d"), "icon": "****"},
	"trust_50": {"title": I18n.t("ach_trust_50"), "desc": I18n.t("ach_trust_50_d"), "icon": "*"},
	"trust_80": {"title": I18n.t("ach_trust_80"), "desc": I18n.t("ach_trust_80_d"), "icon": "**"},
	"first_resilient": {"title": I18n.t("ach_resilient"), "desc": I18n.t("ach_resilient_d"), "icon": "**"},
	"breakthrough": {"title": I18n.t("ach_breakthrough"), "desc": I18n.t("ach_breakthrough_d"), "icon": "***"},
	"unlock_zhang": {"title": I18n.t("ach_unlock_zhang"), "desc": I18n.t("ach_unlock_zhang_d"), "icon": "*"},
	"unlock_wang_mei": {"title": I18n.t("ach_unlock_wang"), "desc": I18n.t("ach_unlock_wang_d"), "icon": "**"},
}

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	GameManager.achievement_unlocked.connect(_on_achievement)

func _on_achievement(achievement_id: String):
	var def: Dictionary = _achievement_defs.get(achievement_id, {})
	if def.is_empty():
		def = {"title": achievement_id, "desc": I18n.t("achievement_unlocked"), "icon": "*"}
	_queue.append(def)
	if not visible:
		_show_next()

func _show_next():
	if _queue.is_empty():
		visible = false
		return
	var def: Dictionary = _queue.pop_front()
	icon_label.text = def.get("icon", "*")
	title_label.text = "%s: %s" % [I18n.t("achievement_unlocked"), def.get("title", "")]
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
