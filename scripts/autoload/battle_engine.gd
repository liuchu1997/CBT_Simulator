extends Node

signal state_changed(patient_id: String, new_state: String)
signal alliance_changed(patient_id: String, new_value: int)
signal schema_discovered(patient_id: String, schema: String)
signal battle_effect(patient_id: String, skill: String, effectiveness: String, delta_text: String)

enum EmotionState {
	GUARDED,
	TESTING,
	OPENING_UP,
	EMOTIONALLY_FLOODED,
	RESISTANT,
	REFLECTIVE,
	INSIGHT,
}

var _state_names: Dictionary = {
	EmotionState.GUARDED: "防御",
	EmotionState.TESTING: "试探",
	EmotionState.OPENING_UP: "敞开心扉",
	EmotionState.EMOTIONALLY_FLOODED: "情绪泛滥",
	EmotionState.RESISTANT: "抗拒",
	EmotionState.REFLECTIVE: "反思",
	EmotionState.INSIGHT: "领悟",
}

var _patient_data: Dictionary = {}

var _effectiveness: Dictionary = {
	"reflection": {
		EmotionState.GUARDED: 3.0,
		EmotionState.TESTING: 2.0,
		EmotionState.OPENING_UP: 2.0,
		EmotionState.EMOTIONALLY_FLOODED: 3.0,
		EmotionState.RESISTANT: 2.0,
		EmotionState.REFLECTIVE: 1.0,
		EmotionState.INSIGHT: 1.0,
	},
	"validation": {
		EmotionState.GUARDED: 3.0,
		EmotionState.TESTING: 3.0,
		EmotionState.OPENING_UP: 2.0,
		EmotionState.EMOTIONALLY_FLOODED: 2.0,
		EmotionState.RESISTANT: 2.0,
		EmotionState.REFLECTIVE: 1.0,
		EmotionState.INSIGHT: 1.0,
	},
	"active_listening": {
		EmotionState.GUARDED: 2.0,
		EmotionState.TESTING: 2.0,
		EmotionState.OPENING_UP: 3.0,
		EmotionState.EMOTIONALLY_FLOODED: 1.0,
		EmotionState.RESISTANT: 1.5,
		EmotionState.REFLECTIVE: 2.0,
		EmotionState.INSIGHT: 1.0,
	},
	"empathy": {
		EmotionState.GUARDED: 2.5,
		EmotionState.TESTING: 2.0,
		EmotionState.OPENING_UP: 2.5,
		EmotionState.EMOTIONALLY_FLOODED: 3.0,
		EmotionState.RESISTANT: 1.5,
		EmotionState.REFLECTIVE: 1.5,
		EmotionState.INSIGHT: 1.0,
	},
	"socratic_questioning": {
		EmotionState.GUARDED: 0.3,
		EmotionState.TESTING: 1.0,
		EmotionState.OPENING_UP: 2.0,
		EmotionState.EMOTIONALLY_FLOODED: 0.3,
		EmotionState.RESISTANT: 0.5,
		EmotionState.REFLECTIVE: 3.0,
		EmotionState.INSIGHT: 2.0,
	},
	"cognitive_restructuring": {
		EmotionState.GUARDED: 0.1,
		EmotionState.TESTING: 0.5,
		EmotionState.OPENING_UP: 1.5,
		EmotionState.EMOTIONALLY_FLOODED: 0.1,
		EmotionState.RESISTANT: 0.3,
		EmotionState.REFLECTIVE: 3.0,
		EmotionState.INSIGHT: 3.0,
	},
	"rapport": {
		EmotionState.GUARDED: 1.0,
		EmotionState.TESTING: 1.5,
		EmotionState.OPENING_UP: 1.0,
		EmotionState.EMOTIONALLY_FLOODED: 0.5,
		EmotionState.RESISTANT: 0.5,
		EmotionState.REFLECTIVE: 1.0,
		EmotionState.INSIGHT: 1.0,
	},
}

var _category_to_skill: Dictionary = {
	"empathy": "empathy",
	"active_listening": "active_listening",
	"socratic_questioning": "socratic_questioning",
	"cognitive_restructuring": "cognitive_restructuring",
	"rapport": "rapport",
}

func init_patient(patient_id: String, config: Dictionary = {}):
	var data := {
		"emotional_state": config.get("initial_state", EmotionState.GUARDED),
		"alliance": config.get("alliance", 20),
		"anxiety": config.get("anxiety", 50),
		"depression": config.get("depression", 50),
		"defensiveness": config.get("defensiveness", 40),
		"insight": config.get("insight", 10),
		"avoidance": config.get("avoidance", 30),
		"hope": config.get("hope", 20),
		"hidden_schemas": config.get("hidden_schemas", []),
		"discovered_schemas": [],
		"state_history": [],
		"turn_count": 0,
		"bad_moves_in_row": 0,
	}
	_patient_data[patient_id] = data

func get_state(patient_id: String) -> int:
	if not _patient_data.has(patient_id):
		return EmotionState.GUARDED
	return _patient_data[patient_id]["emotional_state"]

func get_state_name(patient_id: String) -> String:
	return _state_names.get(get_state(patient_id), "未知")

func get_alliance(patient_id: String) -> int:
	if not _patient_data.has(patient_id):
		return 20
	return _patient_data[patient_id]["alliance"]

func get_stat(patient_id: String, stat_name: String) -> int:
	if not _patient_data.has(patient_id):
		return 0
	return _patient_data[patient_id].get(stat_name, 0)

func get_hidden_schemas(patient_id: String) -> Array:
	if not _patient_data.has(patient_id):
		return []
	return _patient_data[patient_id].get("hidden_schemas", [])

func get_discovered_schemas(patient_id: String) -> Array:
	if not _patient_data.has(patient_id):
		return []
	return _patient_data[patient_id].get("discovered_schemas", [])

func get_turn_count(patient_id: String) -> int:
	if not _patient_data.has(patient_id):
		return 0
	return _patient_data[patient_id]["turn_count"]

func apply_skill(patient_id: String, category: String, base_points: int) -> Dictionary:
	if not _patient_data.has(patient_id):
		return _make_result(base_points, "neutral", "无状态", 0, 0)
	
	var data: Dictionary = _patient_data[patient_id]
	var state: int = data["emotional_state"]
	var skill_name: String = _category_to_skill.get(category, category)
	var eff: float = 1.0
	
	if _effectiveness.has(skill_name) and _effectiveness[skill_name].has(state):
		eff = _effectiveness[skill_name][state]
	
	var actual_points: int = int(roundf(base_points * eff))
	if base_points > 0 and eff < 0.5:
		actual_points = -absi(base_points)
	
	var alliance_delta: int = _calc_alliance_delta(eff, base_points)
	data["alliance"] = clampi(data["alliance"] + alliance_delta, 0, 100)
	
	data["turn_count"] += 1
	if eff >= 2.0:
		data["bad_moves_in_row"] = 0
	elif eff <= 0.5:
		data["bad_moves_in_row"] += 1
	else:
		data["bad_moves_in_row"] = 0
	
	var eff_label: String = _get_effectiveness_label(eff)
	var delta_text: String = "%+d" % alliance_delta
	
	_update_secondary_stats(data, category, eff)
	_check_state_transition(patient_id, data, eff, base_points)
	_check_schema_discovery(patient_id, data, eff)
	
	alliance_changed.emit(patient_id, data["alliance"])
	battle_effect.emit(patient_id, skill_name, eff_label, delta_text)
	
	return _make_result(actual_points, eff_label, _state_names.get(state, "?"), alliance_delta, data["emotional_state"])

func _calc_alliance_delta(eff: float, base_points: int) -> int:
	if base_points <= 0:
		return -5
	if eff >= 3.0:
		return 10
	if eff >= 2.0:
		return 5
	if eff >= 1.0:
		return 2
	if eff >= 0.5:
		return -3
	return -10

func _update_secondary_stats(data: Dictionary, category: String, eff: float):
	if eff >= 1.5:
		data["defensiveness"] = maxi(data["defensiveness"] - 3, 0)
		data["insight"] = mini(data["insight"] + 2, 100)
		if category == "socratic_questioning":
			data["insight"] = mini(data["insight"] + 3, 100)
		if category == "empathy":
			data["anxiety"] = maxi(data["anxiety"] - 3, 0)
			data["depression"] = maxi(data["depression"] - 2, 0)
			data["hope"] = mini(data["hope"] + 2, 100)
		if category == "cognitive_restructuring":
			data["avoidance"] = maxi(data["avoidance"] - 3, 0)
	elif eff <= 0.5:
		data["defensiveness"] = mini(data["defensiveness"] + 5, 100)
		data["anxiety"] = mini(data["anxiety"] + 3, 100)
		if eff <= 0.3:
			data["defensiveness"] = mini(data["defensiveness"] + 8, 100)

func _check_state_transition(patient_id: String, data: Dictionary, eff: float, base_points: int):
	var old_state: int = data["emotional_state"]
	var alliance: int = data["alliance"]
	var defen: int = data["defensiveness"]
	var ins: int = data["insight"]
	var new_state: int = old_state
	
	if eff <= 0.3 and base_points > 0:
		new_state = EmotionState.RESISTANT
	elif eff <= 0.5 and base_points > 0 and old_state != EmotionState.RESISTANT:
		new_state = EmotionState.GUARDED
	elif old_state == EmotionState.GUARDED:
		if alliance >= 30 and eff >= 1.5:
			new_state = EmotionState.TESTING
	elif old_state == EmotionState.TESTING:
		if alliance >= 50 and eff >= 2.0:
			new_state = EmotionState.OPENING_UP
		if data["bad_moves_in_row"] >= 2:
			new_state = EmotionState.GUARDED
	elif old_state == EmotionState.OPENING_UP:
		if data["anxiety"] >= 80 or data["depression"] >= 80:
			new_state = EmotionState.EMOTIONALLY_FLOODED
		if ins >= 30 and alliance >= 60:
			new_state = EmotionState.REFLECTIVE
		if data["bad_moves_in_row"] >= 2:
			new_state = EmotionState.TESTING
	elif old_state == EmotionState.EMOTIONALLY_FLOODED:
		if eff >= 2.5 and category_is_emotional(data.get("last_category", "")):
			new_state = EmotionState.OPENING_UP
		if data["bad_moves_in_row"] >= 1:
			new_state = EmotionState.RESISTANT
	elif old_state == EmotionState.RESISTANT:
		if eff >= 2.5:
			new_state = EmotionState.TESTING
		if data["bad_moves_in_row"] >= 3:
			new_state = EmotionState.GUARDED
	elif old_state == EmotionState.REFLECTIVE:
		if ins >= 60 and alliance >= 70:
			new_state = EmotionState.INSIGHT
		if data["bad_moves_in_row"] >= 2:
			new_state = EmotionState.OPENING_UP
	
	if new_state != old_state:
		data["emotional_state"] = new_state
		data["state_history"].append({"from": old_state, "to": new_state, "turn": data["turn_count"]})
		state_changed.emit(patient_id, _state_names.get(new_state, "?"))

func category_is_emotional(cat: String) -> bool:
	return cat in ["empathy", "validation", "reflection"]

func _check_schema_discovery(patient_id: String, data: Dictionary, eff: float):
	if eff < 2.0:
		return
	var schemas: Array = data.get("hidden_schemas", [])
	var discovered: Array = data.get("discovered_schemas", [])
	var chance := (eff - 1.0) * 0.3
	var alliance: int = data["alliance"]
	if alliance >= 50:
		chance += 0.2
	for schema in schemas:
		if not schema in discovered and randf() < chance:
			discovered.append(schema)
			schema_discovered.emit(patient_id, schema)
	data["discovered_schemas"] = discovered

func _get_effectiveness_label(eff: float) -> String:
	if eff >= 3.0:
		return "效果拔群！"
	if eff >= 2.0:
		return "很有效！"
	if eff >= 1.0:
		return "一般..."
	if eff >= 0.5:
		return "效果不佳..."
	return "完全无效！"

func _make_result(points: int, eff_label: String, state_name: String, alliance_delta: int, new_state: int) -> Dictionary:
	return {
		"actual_points": points,
		"effectiveness_label": eff_label,
		"patient_state": state_name,
		"alliance_delta": alliance_delta,
		"new_state": new_state,
	}

func reset_patient(patient_id: String):
	_patient_data.erase(patient_id)

func get_patient_data(patient_id: String) -> Dictionary:
	return _patient_data.get(patient_id, {})

func get_alliance_bar_value(patient_id: String) -> float:
	return float(get_alliance(patient_id)) / 100.0

func get_stat_bar_value(patient_id: String, stat_name: String) -> float:
	return float(get_stat(patient_id, stat_name)) / 100.0
