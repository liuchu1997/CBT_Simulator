extends Node

signal choice_made(category: String, points: int)
signal session_scored(result: Dictionary)

var session_log: Array[Dictionary] = []
var session_scores: Dictionary = {}

const MAX_PER_CATEGORY := 20

func start_new_session():
	session_log.clear()
	session_scores = {
		"empathy": 0,
		"active_listening": 0,
		"socratic_questioning": 0,
		"cognitive_restructuring": 0,
		"rapport": 0,
	}

func log_choice(choice_id: String, category: String, points: int, feedback: String = "", effectiveness: String = ""):
	var actual_points := points
	if SkillTree:
		var mult: float = SkillTree.get_score_multiplier(category)
		if points > 0 and mult > 1.0:
			actual_points = int(ceilf(points * mult))
	
	session_log.append({
		"choice": choice_id,
		"category": category,
		"points": actual_points,
		"base_points": points,
		"feedback": feedback,
		"effectiveness": effectiveness,
	})
	if session_scores.has(category):
		session_scores[category] = clampi(session_scores[category] + actual_points, 0, MAX_PER_CATEGORY)
	choice_made.emit(category, actual_points)

func evaluate_session() -> Dictionary:
	var total := 0
	for cat in session_scores:
		total += session_scores[cat]
	
	var good_choices: Array[String] = []
	var bad_choices: Array[String] = []
	var effect_labels: Array[String] = []
	for entry in session_log:
		if entry["points"] >= 3:
			good_choices.append(entry["feedback"])
		elif entry["points"] <= 0:
			bad_choices.append(entry["feedback"])
		var eff: String = entry.get("effectiveness", "")
		if eff != "" and eff != "一般":
			effect_labels.append(eff)
	
	var patient_id: String = GameManager.current_patient_id
	var emotion_state: String = ""
	var alliance_val: int = 0
	if BattleEngine and BattleEngine.get_patient_data(patient_id).size() > 0:
		emotion_state = BattleEngine.get_state_name(patient_id)
		alliance_val = BattleEngine.get_alliance(patient_id)
	
	var result := {
		"scores": session_scores.duplicate(),
		"total": total,
		"max_possible": MAX_PER_CATEGORY * 5,
		"grade": get_grade(total),
		"good_choices": good_choices,
		"bad_choices": bad_choices,
		"effectiveness_labels": effect_labels,
		"emotion_state": emotion_state,
		"alliance": alliance_val,
		"feedback": generate_feedback(session_scores),
	}
	session_scored.emit(result)
	return result

static func get_grade(score: int) -> String:
	if score >= 50: return "S"
	if score >= 40: return "A"
	if score >= 30: return "B"
	if score >= 18: return "C"
	return "D"

static func generate_feedback(scores: Dictionary) -> String:
	var weakest := ""
	var lowest := 100
	for cat in scores:
		if scores[cat] < lowest:
			lowest = scores[cat]
			weakest = cat
	
	var tips := {
		"empathy": "尝试更多地反映患者的情感，让他们感到被理解。",
		"active_listening": "多使用开放式问题，让患者充分表达。",
		"socratic_questioning": "尝试用提问引导患者自己发现思维中的不合理之处。",
		"cognitive_restructuring": "帮助患者识别认知扭曲，并引导他们找到替代的合理想法。",
		"rapport": "注意建立信任关系，不要急于给建议。",
	}
	
	if lowest >= 8:
		return "表现出色！继续保持这种专业的治疗风格。"
	return tips.get(weakest, "继续努力！")
