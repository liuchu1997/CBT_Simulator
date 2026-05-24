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
		if eff != "" and eff != I18n.t("effectiveness_normal"):
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
		"empathy": I18n.t("tip_empathy") if I18n else "Try to reflect the patient's emotions more.",
		"active_listening": I18n.t("tip_listening") if I18n else "Use more open-ended questions.",
		"socratic_questioning": I18n.t("tip_socratic") if I18n else "Guide the patient to discover irrational thoughts.",
		"cognitive_restructuring": I18n.t("tip_cognitive") if I18n else "Help identify cognitive distortions.",
		"rapport": I18n.t("tip_rapport") if I18n else "Build trust, don't rush to give advice.",
	}
	
	if lowest >= 8:
		return I18n.t("tip_excellent") if I18n else "Excellent! Keep up the professional style."
	return tips.get(weakest, "继续努力！")
