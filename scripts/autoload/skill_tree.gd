extends Node

signal skill_upgraded(skill_line: String, new_level: int)

var _skill_data: Dictionary = {
	"cognitive": {
		"name_key": "skill_cognitive",
		"level_keys": ["skill_identify_distortion", "skill_socratic", "skill_thought_record", "skill_cognitive"],
	},
	"behavioral": {
		"name_key": "skill_behavioral",
		"level_keys": ["skill_activity_schedule", "skill_exposure", "skill_behavior_exp", "skill_mindfulness"],
	},
	"empathic": {
		"name_key": "skill_empathic",
		"level_keys": ["skill_active_listening", "skill_emotion_reflect", "skill_unconditional", "skill_alliance"],
	},
}

func upgrade_skill(skill_line: String) -> bool:
	if not _skill_data.has(skill_line):
		return false
	if GameManager.skill_points <= 0:
		return false
	var current: int = GameManager.skills.get(skill_line, 0)
	if current >= 4:
		return false
	GameManager.skills[skill_line] = current + 1
	GameManager.skill_points -= 1
	skill_upgraded.emit(skill_line, current + 1)
	_check_skill_achievements()
	GameManager.save_game()
	return true

func get_skill_level(skill_line: String) -> int:
	return GameManager.skills.get(skill_line, 0)

func get_skill_name(skill_line: String) -> String:
	var key: String = _skill_data.get(skill_line, {}).get("name_key", "")
	if key != "" and I18n:
		return I18n.t(key)
	return skill_line

func get_level_name(skill_line: String, level: int) -> String:
	var level_keys: Array = _skill_data.get(skill_line, {}).get("level_keys", [])
	if level > 0 and level <= level_keys.size():
		var key: String = level_keys[level - 1]
		if I18n:
			return I18n.t(key)
	return ""

func get_all_lines() -> Array[String]:
	var result: Array[String] = []
	for key in _skill_data:
		result.append(key)
	return result

func get_score_multiplier(category: String) -> float:
	var mult: float = 1.0
	var cognitive: int = GameManager.skills.get("cognitive", 0)
	var behavioral: int = GameManager.skills.get("behavioral", 0)
	var empathic: int = GameManager.skills.get("empathic", 0)
	
	match category:
		"socratic_questioning":
			if cognitive >= 2: mult += 0.2
		"cognitive_restructuring":
			if cognitive >= 3: mult += 0.3
		"active_listening":
			if behavioral >= 1: mult += 0.1
		"empathy":
			if empathic >= 1: mult += 0.15
		"rapport":
			if empathic >= 3: mult += 0.2
	return mult

func get_bond_bonus() -> int:
	var empathic: int = GameManager.skills.get("empathic", 0)
	if empathic >= 3: return 3
	if empathic >= 2: return 2
	if empathic >= 1: return 1
	return 0

func _check_skill_achievements() -> void:
	var cog: int = GameManager.skills.get("cognitive", 0)
	var beh: int = GameManager.skills.get("behavioral", 0)
	var emp: int = GameManager.skills.get("empathic", 0)
	if cog >= 4:
		GameManager._check_achievement("cognitive_master")
	if beh >= 4:
		GameManager._check_achievement("behavioral_master")
	if emp >= 4:
		GameManager._check_achievement("empathic_master")
	if cog >= 4 and beh >= 4 and emp >= 4:
		GameManager._check_achievement("all_skills_max")
