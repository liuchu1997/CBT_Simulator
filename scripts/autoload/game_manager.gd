extends Node

signal session_started(patient_id: String, session_num: int)
signal session_ended(patient_id: String, session_num: int)
signal patient_unlocked(patient_id: String)
signal chapter_completed(chapter_id: String)
signal score_updated(patient_id: String)
signal bond_changed(patient_id: String, new_value: int)
signal emotion_state_changed(patient_id: String, category: String, new_state: String)
signal achievement_unlocked(achievement_id: String)
signal tutorial_trigger(tutorial_id: String)
signal game_reset
signal chapter_failed(chapter_id: String, reason: String)

const PATIENT_NAMES := {"lin_xiaoyu": "林小雨", "zhang_hao": "张浩", "wang_mei": "王美"}
const BOND_DEFAULTS := {"lin_xiaoyu": 30, "zhang_hao": 25, "wang_mei": 20}

var current_patient_id: String = ""
var current_session_num: int = 0
var game_state: String = "menu"

var unlocked_patients: Array[String] = ["lin_xiaoyu"]
var completed_sessions: Dictionary = {}
var patient_scores: Dictionary = {}
var total_score: int = 0
var therapist_level: int = 1
var skill_points: int = 0

var patient_bond: Dictionary = {}
var patient_emotion_states: Dictionary = {}
var skills: Dictionary = {"cognitive": 0, "behavioral": 0, "empathic": 0}
var therapy_journal: Array[Dictionary] = []
var learned_strategies: Dictionary = {}
var achievements: Dictionary = {}
var tutorials_shown: Dictionary = {}
var total_sessions_count: int = 0
var s_grade_count: int = 0
var completed_chapters: Array[String] = []
var current_chapter: String = "chapter_1"
var homework: Dictionary = {}
var therapy_goals: Dictionary = {}

var _save_path: String = "user://save_data.json"

var _chapter_defs: Dictionary = {
	"chapter_1": {
		"title": "第一章：初入诊室",
		"patient_id": "lin_xiaoyu",
		"required_sessions": 3,
		"min_grade": "D",
		"unlock_next": "chapter_2",
		"skill_requirements": {},
	},
	"chapter_2": {
		"title": "第二章：焦虑的面具",
		"patient_id": "zhang_hao",
		"required_sessions": 3,
		"min_grade": "D",
		"unlock_next": "chapter_3",
		"skill_requirements": {"cognitive": 1, "empathic": 1},
	},
	"chapter_3": {
		"title": "第三章：自我归因",
		"patient_id": "wang_mei",
		"required_sessions": 3,
		"min_grade": "C",
		"unlock_next": "chapter_final",
		"skill_requirements": {"cognitive": 2, "empathic": 2},
	},
	"chapter_final": {
		"title": "终章：治疗师的成长",
		"patient_id": "final_review",
		"required_sessions": 1,
		"min_grade": "B",
		"unlock_next": "",
		"skill_requirements": {"cognitive": 3, "behavioral": 2, "empathic": 3},
	},
}

func _ready():
	load_game()

func get_chapter_def(chapter_id: String) -> Dictionary:
	return _chapter_defs.get(chapter_id, {})

func get_current_chapter_title() -> String:
	return _chapter_defs.get(current_chapter, {}).get("title", "")

func get_chapter_skill_requirements(chapter_id: String) -> Dictionary:
	return _chapter_defs.get(chapter_id, {}).get("skill_requirements", {})

func meets_skill_requirements(chapter_id: String) -> bool:
	var reqs: Dictionary = get_chapter_skill_requirements(chapter_id)
	for skill_line in reqs:
		var needed: int = reqs[skill_line]
		var current: int = skills.get(skill_line, 0)
		if current < needed:
			return false
	return true

func get_missing_skills_text(chapter_id: String) -> String:
	var reqs: Dictionary = get_chapter_skill_requirements(chapter_id)
	var lines: Array[String] = []
	for skill_line in reqs:
		var needed: int = reqs[skill_line]
		var current: int = skills.get(skill_line, 0)
		if current < needed:
			var name: String = SkillTree.get_skill_name(skill_line) if SkillTree else skill_line
			lines.append("%s Lv.%d→%d" % [name, current, needed])
	return "\n".join(lines)

func is_chapter_completed(chapter_id: String) -> bool:
	return chapter_id in completed_chapters

func get_chapter_status_text() -> String:
	var def: Dictionary = _chapter_defs.get(current_chapter, {})
	if def.is_empty():
		return ""
	var pid: String = def.get("patient_id", "")
	if pid == "" or pid == "final_review":
		return ""
	var progress: int = completed_sessions.get(pid, 0)
	var needed: int = def.get("required_sessions", 3)
	var min_g: String = def.get("min_grade", "D")
	
	if progress < needed:
		return ""
	
	var scores: Array = patient_scores.get(pid, [])
	if scores.size() > needed:
		scores = scores.slice(scores.size() - needed, scores.size())
	var worst_grade: String = "S"
	var grade_order := ["D", "C", "B", "A", "S"]
	for s_data in scores:
		var g: String = s_data.get("grade", "D")
		var g_idx: int = grade_order.find(g)
		var min_idx: int = grade_order.find(min_g)
		if g_idx < min_idx:
			if grade_order.find(worst_grade) > g_idx:
				worst_grade = g
	
	if worst_grade == "S":
		return ""
	
	return "评级不达标: 需要达到%s级，最低评级为%s级" % [min_g, worst_grade]

func reset_patient_progress(patient_id: String):
	completed_sessions[patient_id] = 0
	patient_scores.erase(patient_id)
	var bond_default := BOND_DEFAULTS
	patient_bond[patient_id] = bond_default.get(patient_id, 20)
	if BattleEngine:
		BattleEngine.reset_patient(patient_id)
	
	var target_chapter := ""
	for ch_id in _chapter_defs:
		if _chapter_defs[ch_id].get("patient_id", "") == patient_id:
			target_chapter = ch_id
			break
	
	if target_chapter == "":
		return
	
	var chapter_order := ["chapter_1", "chapter_2", "chapter_3", "chapter_final"]
	var target_idx: int = chapter_order.find(target_chapter)
	for i in range(target_idx, chapter_order.size()):
		completed_chapters.erase(chapter_order[i])
	
	_last_failed_chapter = ""
	current_chapter = target_chapter

var _last_failed_chapter: String = ""

func check_chapter_completion() -> bool:
	var def: Dictionary = _chapter_defs.get(current_chapter, {})
	if def.is_empty():
		return false
	var pid: String = def.get("patient_id", "")
	var needed: int = def.get("required_sessions", 3)
	var progress: int = completed_sessions.get(pid, 0)
	
	if progress < needed:
		return false
	
	if pid == "" or pid == "final_review":
		if not completed_chapters.has(current_chapter):
			completed_chapters.append(current_chapter)
			chapter_completed.emit(current_chapter)
		return true
	
	var scores: Array = patient_scores.get(pid, [])
	if scores.size() > needed:
		scores = scores.slice(scores.size() - needed, scores.size())
	var meets_grade := true
	var min_g: String = def.get("min_grade", "D")
	var grade_order := ["D", "C", "B", "A", "S"]
	var min_idx: int = grade_order.find(min_g)
	for s_data in scores:
		var g: String = s_data.get("grade", "D")
		var g_idx: int = grade_order.find(g)
		if g_idx < min_idx:
			meets_grade = false
			break
	
	if not meets_grade:
		var worst_g: String = "S"
		for s_data in scores:
			var g: String = s_data.get("grade", "D")
			if grade_order.find(g) < grade_order.find(worst_g):
				worst_g = g
		if _last_failed_chapter != current_chapter:
			_last_failed_chapter = current_chapter
			chapter_failed.emit(current_chapter, "需要%s级以上，有治疗评级为%s级" % [min_g, worst_g])
		return false
	
	_last_failed_chapter = ""
	if not completed_chapters.has(current_chapter):
		completed_chapters.append(current_chapter)
		chapter_completed.emit(current_chapter)
	
	var next: String = def.get("unlock_next", "")
	if next != "" and not next in completed_chapters:
		var next_pid: String = _chapter_defs.get(next, {}).get("patient_id", "")
		if next_pid != "" and not next_pid in unlocked_patients:
			unlocked_patients.append(next_pid)
			patient_unlocked.emit(next_pid)
		current_chapter = next
	
	return true

func start_session(patient_id: String):
	current_patient_id = patient_id
	if not completed_sessions.has(patient_id):
		completed_sessions[patient_id] = 0
	current_session_num = completed_sessions[patient_id] + 1
	game_state = "session"
	session_started.emit(patient_id, current_session_num)

func end_session(score_data: Dictionary):
	if not patient_scores.has(current_patient_id):
		patient_scores[current_patient_id] = []
	patient_scores[current_patient_id].append(score_data)
	completed_sessions[current_patient_id] = current_session_num
	
	var session_score: int = score_data.get("total", 0)
	total_score += session_score
	therapist_level = 1 + total_score / 200
	skill_points += 1
	if score_data.get("grade", "") == "S":
		skill_points += 1
		s_grade_count += 1
	
	total_sessions_count += 1
	
	_update_emotion_states_from_session(current_patient_id, score_data)
	_add_journal_entry(current_patient_id, current_session_num, score_data)
	_check_achievements()
	check_chapter_completion()
	
	game_state = "explore"
	session_ended.emit(current_patient_id, current_session_num)
	score_updated.emit(current_patient_id)
	save_game()

func get_patient_progress(patient_id: String) -> int:
	return completed_sessions.get(patient_id, 0)

func is_patient_unlocked(patient_id: String) -> bool:
	return patient_id in unlocked_patients

func get_bond(patient_id: String) -> int:
	if patient_bond.has(patient_id):
		return patient_bond[patient_id]
	var defaults := BOND_DEFAULTS
	return defaults.get(patient_id, 20)

func modify_bond(patient_id: String, amount: int):
	var old := get_bond(patient_id)
	var new_val := clampi(old + amount, 0, 100)
	patient_bond[patient_id] = new_val
	
	var old_milestone := old / 20
	var new_milestone := new_val / 20
	if new_milestone > old_milestone and amount > 0:
		tutorial_trigger.emit("trust_up")
	if amount < 0:
		tutorial_trigger.emit("bond_decay")
	
	bond_changed.emit(patient_id, new_val)

func check_bond_decay():
	var to_decay: Array[String] = []
	for pid in patient_bond:
		if completed_sessions.has(pid):
			var last_session: int = completed_sessions[pid]
			var current_max: int = 0
			for v in completed_sessions.values():
				if v > current_max:
					current_max = v
			if current_max - last_session >= 3 and patient_bond[pid] > 10:
				to_decay.append(pid)
	for pid in to_decay:
		modify_bond(pid, -2)

func get_bond_level(patient_id: String) -> String:
	var b := get_bond(patient_id)
	if b >= 80: return "deep"
	if b >= 60: return "open"
	if b >= 40: return "warm"
	if b >= 20: return "guarded"
	return "closed"

func get_emotion_state(patient_id: String, category: String) -> String:
	if patient_emotion_states.has(patient_id) and patient_emotion_states[patient_id].has(category):
		return patient_emotion_states[patient_id][category]
	return "active"

func set_emotion_state(patient_id: String, category: String, state: String):
	if not patient_emotion_states.has(patient_id):
		patient_emotion_states[patient_id] = {}
	var old_state: String = patient_emotion_states[patient_id].get(category, "active")
	patient_emotion_states[patient_id][category] = state
	if old_state != state:
		emotion_state_changed.emit(patient_id, category, state)
		if state == "resilient":
			_check_achievement("first_resilient")
		if state == "resilient" and get_bond(patient_id) >= 60:
			_check_achievement("breakthrough")

func _update_emotion_states_from_session(patient_id: String, score_data: Dictionary):
	var total: int = score_data.get("total", 0)
	var bond_val: int = get_bond(patient_id)
	
	var primary_emotion: String = "depression"
	var secondary_emotion: String = "anxiety"
	match patient_id:
		"zhang_hao":
			primary_emotion = "anxiety"
			secondary_emotion = "depression"
		"wang_mei":
			primary_emotion = "anxiety"
			secondary_emotion = "depression"
	
	var current_primary: String = get_emotion_state(patient_id, primary_emotion)
	if current_primary == "active" and total >= 5:
		set_emotion_state(patient_id, primary_emotion, "recovering")
	if current_primary == "recovering" and total >= 7 and bond_val >= 50:
		set_emotion_state(patient_id, primary_emotion, "resilient")
	
	var current_secondary: String = get_emotion_state(patient_id, secondary_emotion)
	if current_secondary == "active" and total >= 6:
		set_emotion_state(patient_id, secondary_emotion, "recovering")
	if current_secondary == "recovering" and total >= 8 and bond_val >= 40:
		set_emotion_state(patient_id, secondary_emotion, "resilient")

func get_patient_emotion_summary(patient_id: String) -> String:
	var states: Dictionary = patient_emotion_states.get(patient_id, {})
	var result := ""
	for cat in states:
		result += "%s:%s " % [cat, states[cat]]
	if result == "":
		result = "初始评估中"
	return result

func assign_homework(patient_id: String, task: String, detail: String):
	homework[patient_id] = {"task": task, "detail": detail, "assigned_session": current_session_num, "completed": false}

func complete_homework(patient_id: String):
	if homework.has(patient_id):
		homework[patient_id]["completed"] = true

func get_homework(patient_id: String) -> Dictionary:
	return homework.get(patient_id, {})

func has_pending_homework(patient_id: String) -> bool:
	var hw: Dictionary = homework.get(patient_id, {})
	return not hw.is_empty() and not hw.get("completed", true)

func set_therapy_goal(patient_id: String, goal: String):
	therapy_goals[patient_id] = goal

func get_therapy_goal(patient_id: String) -> String:
	return therapy_goals.get(patient_id, "")

func _add_journal_entry(patient_id: String, session_num: int, score_data: Dictionary):
	var entry := {
		"patient_id": patient_id,
		"session": session_num,
		"score_total": score_data.get("total", 0),
		"grade": score_data.get("grade", "D"),
		"bond_after": get_bond(patient_id),
		"emotions": patient_emotion_states.get(patient_id, {}).duplicate(),
	}
	therapy_journal.append(entry)

func learn_strategy(strategy_id: String):
	learned_strategies[strategy_id] = "found"

func mark_strategy_read(strategy_id: String):
	learned_strategies[strategy_id] = "read"

func _check_achievements():
	_check_achievement("first_session")
	if total_sessions_count >= 5:
		_check_achievement("five_sessions")
	if s_grade_count >= 1:
		_check_achievement("perfect_score")
	for pid in patient_bond:
		if patient_bond[pid] >= 50:
			_check_achievement("trust_50")
		if patient_bond[pid] >= 80:
			_check_achievement("trust_80")
	if "zhang_hao" in unlocked_patients:
		_check_achievement("unlock_zhang")
	if "wang_mei" in unlocked_patients:
		_check_achievement("unlock_wang_mei")

func _check_achievement(achievement_id: String):
	if achievements.has(achievement_id) and achievements[achievement_id]:
		return
	achievements[achievement_id] = true
	achievement_unlocked.emit(achievement_id)

func reset_game():
	current_patient_id = ""
	current_session_num = 0
	game_state = "menu"
	unlocked_patients = ["lin_xiaoyu"]
	completed_sessions.clear()
	patient_scores.clear()
	total_score = 0
	therapist_level = 1
	skill_points = 0
	patient_bond.clear()
	patient_emotion_states.clear()
	skills = {"cognitive": 0, "behavioral": 0, "empathic": 0}
	therapy_journal.clear()
	learned_strategies.clear()
	achievements.clear()
	tutorials_shown.clear()
	total_sessions_count = 0
	s_grade_count = 0
	completed_chapters.clear()
	current_chapter = "chapter_1"
	homework.clear()
	therapy_goals.clear()
	if FileAccess.file_exists(_save_path):
		DirAccess.remove_absolute(_save_path)
	game_reset.emit()
	save_game()

func save_game():
	var data = {
		"unlocked_patients": unlocked_patients,
		"completed_sessions": completed_sessions,
		"patient_scores": patient_scores,
		"total_score": total_score,
		"therapist_level": therapist_level,
		"skill_points": skill_points,
		"skills": skills,
		"patient_bond": patient_bond,
		"patient_emotion_states": patient_emotion_states,
		"therapy_journal": therapy_journal,
		"learned_strategies": learned_strategies,
		"achievements": achievements,
		"tutorials_shown": tutorials_shown,
		"total_sessions_count": total_sessions_count,
		"s_grade_count": s_grade_count,
		"completed_chapters": completed_chapters,
		"current_chapter": current_chapter,
		"homework": homework,
		"therapy_goals": therapy_goals,
	}
	var file = FileAccess.open(_save_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

func load_game():
	if FileAccess.file_exists(_save_path):
		var file = FileAccess.open(_save_path, FileAccess.READ)
		if file:
			var json = JSON.new()
			var err = json.parse(file.get_as_text())
			file.close()
			if err == OK:
				var data = json.data
				var loaded_unlocked: Array = data.get("unlocked_patients", ["lin_xiaoyu"])
				unlocked_patients.clear()
				for item in loaded_unlocked:
					unlocked_patients.append(str(item))
				completed_sessions = data.get("completed_sessions", {})
				patient_scores = data.get("patient_scores", {})
				total_score = int(data.get("total_score", 0))
				therapist_level = int(data.get("therapist_level", 1))
				skill_points = int(data.get("skill_points", 0))
				skills = data.get("skills", {"cognitive": 0, "behavioral": 0, "empathic": 0})
				patient_bond = data.get("patient_bond", {})
				patient_emotion_states = data.get("patient_emotion_states", {})
				therapy_journal.clear()
				var loaded_journal: Array = data.get("therapy_journal", [])
				for entry in loaded_journal:
					therapy_journal.append(entry)
				learned_strategies = data.get("learned_strategies", {})
				achievements = data.get("achievements", {})
				tutorials_shown = data.get("tutorials_shown", {})
				total_sessions_count = int(data.get("total_sessions_count", 0))
				s_grade_count = int(data.get("s_grade_count", 0))
				var loaded_chapters: Array = data.get("completed_chapters", [])
				completed_chapters.clear()
				for ch in loaded_chapters:
					completed_chapters.append(str(ch))
				current_chapter = data.get("current_chapter", "chapter_1")
				homework = data.get("homework", {})
				therapy_goals = data.get("therapy_goals", {})
