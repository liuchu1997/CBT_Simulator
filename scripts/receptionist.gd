extends "res://scripts/npc_base.gd"

var _pending_action: String = ""

func _ready():
	super._ready()
	DialogueManager.choice_selected.connect(_on_choice_selected)

func _on_choice_selected(choice_id: String):
	match choice_id:
		"recep_rp_ok":
			_pending_action = "reset_patient"
		"recep_ra_ok", "recep_full_ok":
			_pending_action = "reset_all"
		_:
			_pending_action = ""

func on_interact():
	if not is_interactable:
		return
	_face_player()
	if DialogueManager.is_active():
		return
	_pending_action = ""
	_build_and_show()

func _build_and_show():
	var d: Array[Dictionary] = []
	var total_sessions := GameManager.total_sessions_count
	var is_stuck := _detect_stuck()
	
	if total_sessions == 0:
		d.append({"speaker": _speaker(), "text": _l("recep_welcome")})
		d.append({"speaker": _speaker(), "text": _l("recep_first_guide")})
		d.append({"speaker": _speaker(), "text": _l("recep_first_tip")})
		DialogueManager.start_dialogue(d)
		return
	
	if is_stuck != "":
		_build_stuck_dialogue(d, is_stuck)
		DialogueManager.start_dialogue(d, _execute_pending)
		return
	
	_build_normal_dialogue(d)
	DialogueManager.start_dialogue(d, _execute_pending)

func _speaker() -> String:
	return I18n.t("receptionist")

func _l(key: String) -> String:
	return I18n.t(key)

func _build_stuck_dialogue(d: Array[Dictionary], stuck_reason: String):
	d.append({"speaker": _speaker(), "text": _l("recep_stuck_intro")})
	d.append({"speaker": _speaker(), "text": stuck_reason})
	d.append({"speaker": _speaker(), "text": _l("recep_stuck_help")})
	d.append({
		"choices": [
			{"text": _l("recep_choice_tips"), "next": "recep_tips"},
			{"text": _l("recep_choice_reset_patient"), "next": "recep_rp_ask"},
			{"text": _l("recep_choice_reset_all"), "next": "recep_ra_ask"},
			{"text": _l("recep_choice_retry"), "next": "recep_go"},
		]
	})
	d.append({"label": "recep_tips", "speaker": _speaker(), "text": _get_therapy_tips()})
	d.append({"label": "recep_rp_ask", "speaker": _speaker(), "text": _l("recep_rp_confirm")})
	d.append({"choices": [
		{"text": _l("recep_choice_confirm"), "next": "recep_rp_ok"},
		{"text": _l("recep_choice_cancel"), "next": "recep_rp_no"},
	]})
	d.append({"label": "recep_rp_ok", "speaker": _speaker(), "text": _l("recep_rp_done")})
	d.append({"label": "recep_rp_no", "speaker": _speaker(), "text": _l("recep_encourage")})
	d.append({"label": "recep_ra_ask", "speaker": _speaker(), "text": _l("recep_ra_confirm")})
	d.append({"choices": [
		{"text": _l("recep_choice_confirm"), "next": "recep_ra_ok"},
		{"text": _l("recep_choice_cancel"), "next": "recep_ra_no"},
	]})
	d.append({"label": "recep_ra_ok", "speaker": _speaker(), "text": _l("recep_ra_done")})
	d.append({"label": "recep_ra_no", "speaker": _speaker(), "text": _l("recep_encourage")})
	d.append({"label": "recep_go", "speaker": _speaker(), "text": _l("recep_go_tip")})

func _build_normal_dialogue(d: Array[Dictionary]):
	d.append({"speaker": _speaker(), "text": _get_progress_summary()})
	d.append({"speaker": _speaker(), "text": _get_hint()})
	d.append({
		"choices": [
			{"text": _l("recep_choice_task"), "next": "recep_task"},
			{"text": _l("recep_choice_advice"), "next": "recep_advice"},
			{"text": _l("recep_choice_reset_all"), "next": "recep_full_ask"},
			{"text": _l("recep_choice_bye"), "next": "recep_bye"},
		]
	})
	d.append({"label": "recep_task", "speaker": _speaker(), "text": _get_task_detail()})
	d.append({"label": "recep_advice", "speaker": _speaker(), "text": _get_therapy_tips()})
	d.append({"label": "recep_full_ask", "speaker": _speaker(), "text": _l("recep_ra_confirm")})
	d.append({"choices": [
		{"text": _l("recep_choice_confirm"), "next": "recep_full_ok"},
		{"text": _l("recep_choice_cancel"), "next": "recep_full_no"},
	]})
	d.append({"label": "recep_full_ok", "speaker": _speaker(), "text": _l("recep_ra_done")})
	d.append({"label": "recep_full_no", "speaker": _speaker(), "text": _l("recep_encourage")})
	d.append({"label": "recep_bye", "speaker": _speaker(), "text": _l("recep_bye_msg")})

func _execute_pending():
	if _pending_action == "reset_patient":
		var ch_def: Dictionary = GameManager.get_chapter_def(GameManager.current_chapter)
		var pid: String = ch_def.get("patient_id", "")
		if pid != "":
			GameManager.reset_patient_progress(pid)
	elif _pending_action == "reset_all":
		GameManager.reset_game()
	_pending_action = ""

func _detect_stuck() -> String:
	var ch_def: Dictionary = GameManager.get_chapter_def(GameManager.current_chapter)
	if ch_def.is_empty():
		return ""
	var pid: String = ch_def.get("patient_id", "")
	var needed: int = ch_def.get("required_sessions", 3)
	var progress: int = GameManager.completed_sessions.get(pid, 0)
	
	if not GameManager.meets_skill_requirements(GameManager.current_chapter):
		var missing: String = GameManager.get_missing_skills_text(GameManager.current_chapter)
		return _l("recep_stuck_skill") % missing
	
	if progress >= needed:
		var status: String = GameManager.get_chapter_status_text()
		if status != "":
			return _l("recep_stuck_grade") % [progress, status]
	
	if progress >= needed + 2:
		return _l("recep_stuck_many")
	
	return ""

func _get_progress_summary() -> String:
	var ch_title: String = GameManager.get_current_chapter_title()
	return "%s Lv.%d | %s | %s %d | %s %d | %s %d" % [
		I18n.t("therapist_level"), GameManager.therapist_level, ch_title,
		I18n.t("journal_count"), GameManager.total_sessions_count,
		I18n.t("total_score"), GameManager.total_score,
		I18n.t("skill_points_label"), GameManager.skill_points]

func _get_hint() -> String:
	var ch_def: Dictionary = GameManager.get_chapter_def(GameManager.current_chapter)
	if ch_def.is_empty():
		return _l("recep_all_done")
	var pid: String = ch_def.get("patient_id", "")
	var progress: int = GameManager.completed_sessions.get(pid, 0)
	var needed: int = ch_def.get("required_sessions", 3)
	var pname: String = GameManager.PATIENT_NAMES.get(pid, "")
	if pname == "":
		return _l("recep_final_chapter")
	if progress == 0:
		return _l("recep_go_find") % [pname, _get_room_hint(pid)]
	if progress < needed:
		return _l("recep_continue") % [pname, needed - progress]
	return _l("recep_enough") % pname

func _get_room_hint(pid: String) -> String:
	match pid:
		"lin_xiaoyu": return _l("recep_room_a")
		"zhang_hao": return _l("recep_room_b")
		"wang_mei": return _l("recep_room_c")
		_: return _l("recep_room_default")

func _get_task_detail() -> String:
	var ch_def: Dictionary = GameManager.get_chapter_def(GameManager.current_chapter)
	if ch_def.is_empty():
		return _l("recep_all_done")
	var pid: String = ch_def.get("patient_id", "")
	var needed: int = ch_def.get("required_sessions", 3)
	var progress: int = GameManager.completed_sessions.get(pid, 0)
	var min_grade: String = ch_def.get("min_grade", "D")
	var pname: String = GameManager.PATIENT_NAMES.get(pid, "")
	var text := "%s%s\n" % [_l("recep_task_chapter"), GameManager.get_current_chapter_title()]
	text += "%s%s\n" % [_l("recep_task_patient"), pname]
	text += "%s%d / %d\n" % [_l("recep_task_progress"), progress, needed]
	text += "%s%s %s" % [_l("recep_task_grade_req"), min_grade, _l("score_grade")]
	if not GameManager.meets_skill_requirements(GameManager.current_chapter):
		text += "\n\n%s" % _l("recep_skill_warning")
	return text

func _get_therapy_tips() -> String:
	var tips := {
		"chapter_1": _l("recep_tip_lin"),
		"chapter_2": _l("recep_tip_zhang"),
		"chapter_3": _l("recep_tip_wang"),
	}
	return tips.get(GameManager.current_chapter, _l("recep_tip_general"))
