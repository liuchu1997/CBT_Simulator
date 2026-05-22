extends Node

var _test_results: Array[String] = []
var _current_test: String = ""
var _patients: Array[Node] = []

var _started := false

func _ready():
	print("\n========== CBT SIMULATOR TEST SUITE ==========")

func _process(_delta: float):
	if _started:
		return
	_started = true
	set_process(false)
	_run_all_tests.call_deferred()

func _run_all_tests():
	
	_test_patient_profiles()
	
	_test_lin_session_1_best()
	
	_test_lin_session_1_worst()
	
	_test_lin_session_2()
	
	_test_lin_session_3()
	
	_test_lin_completion()
	
	_test_zhang_session_1()
	
	_test_scoring_system()
	
	_test_game_manager_full_flow()
	
	_test_trust_system()
	
	_test_emotion_state_machine()
	
	_test_skill_tree()
	
	_test_achievements()
	
	_test_journal()
	
	_test_battle_engine_init()
	
	_test_battle_engine_effectiveness()
	
	_test_battle_engine_state_transition()
	
	_test_battle_engine_schema_discovery()
	
	_cleanup()
	_print_results()
	get_tree().quit()

func _make_patient(pid: String) -> Node:
	var node := CharacterBody2D.new()
	node.set_script(load("res://scripts/patient.gd"))
	node.set("patient_id", pid)
	add_child(node)
	_patients.append(node)
	return node

func _test_patient_profiles():
	_start_test("患者档案初始化")
	var lin = _make_patient("lin_xiaoyu")
	var zhang = _make_patient("zhang_hao")
	
	var lin_emotion: Dictionary = lin.get("emotion") if lin.get("emotion") else {}
	var zhang_emotion: Dictionary = zhang.get("emotion") if zhang.get("emotion") else {}
	
	if lin_emotion.get("depression", -1) != 70:
		_fail("林小雨抑郁: 期望70, 实际%d" % lin_emotion.get("depression", -1))
		return
	if zhang_emotion.get("anxiety", -1) != 80:
		_fail("张浩焦虑: 期望80, 实际%d" % zhang_emotion.get("anxiety", -1))
		return
	
	var lin_dist: Array = lin.get("cognitive_distortions") if lin.get("cognitive_distortions") else []
	if lin_dist.size() != 3:
		_fail("林小雨扭曲: 期望3, 实际%d" % lin_dist.size())
		return
	
	_pass("林小雨: 抑郁=%d 焦虑=%d 希望=%d | 张浩: 焦虑=%d" % [
		lin_emotion.depression, lin_emotion.anxiety, lin_emotion.hope, zhang_emotion.anxiety])

func _test_lin_session_1_best():
	_start_test("林小雨S1-最优选择")
	var p = _make_patient("lin_xiaoyu")
	var dialogue: Array = p._build_session_dialogue(1)
	
	ScoringSystem.start_new_session()
	for entry in dialogue:
		if entry.has("choices"):
			var best := {}
			var best_pts := -100
			for c in entry.choices:
				if c.get("score_points", 0) > best_pts:
					best_pts = c.score_points
					best = c
			if best.size() > 0:
				ScoringSystem.log_choice(best.id, best.score_category, best.score_points, best.feedback)
	
	var result: Dictionary = ScoringSystem.evaluate_session()
	if result.total >= 5:
		_pass("得分: %d, 评级: %s, 好评: %d条" % [result.total, result.grade, result.good_choices.size()])
	else:
		_fail("得分太低: %d" % result.total)

func _test_lin_session_1_worst():
	_start_test("林小雨S1-最差选择")
	var p = _make_patient("lin_xiaoyu")
	var dialogue: Array = p._build_session_dialogue(1)
	
	ScoringSystem.start_new_session()
	for entry in dialogue:
		if entry.has("choices"):
			var worst := {}
			var worst_pts := 100
			for c in entry.choices:
				if c.get("score_points", 0) < worst_pts:
					worst_pts = c.score_points
					worst = c
			if worst.size() > 0:
				ScoringSystem.log_choice(worst.id, worst.score_category, worst.score_points, worst.feedback)
	
	var result: Dictionary = ScoringSystem.evaluate_session()
	if result.bad_choices.size() > 0:
		_pass("得分: %d, 评级: %s, 差评: %d条" % [result.total, result.grade, result.bad_choices.size()])
	else:
		_fail("最差路径应有负面反馈")

func _test_lin_session_2():
	_start_test("林小雨S2-对话完整")
	var p = _make_patient("lin_xiaoyu")
	var dialogue: Array = p._build_session_dialogue(2)
	
	var text_lines := 0
	var choice_nodes := 0
	var total_choices := 0
	for entry in dialogue:
		if entry.has("speaker") and entry.has("text"):
			text_lines += 1
		if entry.has("choices"):
			choice_nodes += 1
			total_choices += entry.choices.size()
	
	if text_lines >= 4 and total_choices >= 3:
		_pass("文本: %d行, 选择点: %d, 选项: %d个" % [text_lines, choice_nodes, total_choices])
	else:
		_fail("内容不足: text=%d choices=%d" % [text_lines, total_choices])

func _test_lin_session_3():
	_start_test("林小雨S3-认知转变")
	var p = _make_patient("lin_xiaoyu")
	var dialogue: Array = p._build_session_dialogue(3)
	
	var has_progress := false
	for entry in dialogue:
		if entry.has("text"):
			var t: String = entry.text
			if "变好" in t or "好起来" in t or "学会" in t or "意识到" in t:
				has_progress = true
	
	if dialogue.size() >= 3 and has_progress:
		_pass("条目: %d, 有正向进展: %s" % [dialogue.size(), has_progress])
	else:
		_fail("S3对话不足或无进展: size=%d progress=%s" % [dialogue.size(), has_progress])

func _test_lin_completion():
	_start_test("林小雨-治疗完成对话")
	var p = _make_patient("lin_xiaoyu")
	var dialogue: Array = p._build_session_dialogue(99)
	
	if dialogue.size() >= 2:
		var texts: Array[String] = []
		for entry in dialogue:
			if entry.has("text"):
				texts.append(entry.text)
		_pass("完成对话: %d条, 内容: %s" % [dialogue.size(), " | ".join(texts)])
	else:
		_fail("完成对话太短: %d" % dialogue.size())

func _test_zhang_session_1():
	_start_test("张浩S1-完整流程")
	var p = _make_patient("zhang_hao")
	var dialogue: Array = p._build_session_dialogue(1)
	
	ScoringSystem.start_new_session()
	var choice_entries := 0
	for entry in dialogue:
		if entry.has("choices"):
			choice_entries += 1
			var c: Dictionary = entry.choices[0]
			ScoringSystem.log_choice(c.id, c.score_category, c.score_points, c.feedback)
	var result: Dictionary = ScoringSystem.evaluate_session()
	
	if dialogue.size() >= 3 and choice_entries >= 1:
		_pass("条目: %d, 选择点: %d, 得分: %d, 评级: %s" % [dialogue.size(), choice_entries, result.total, result.grade])
	else:
		_fail("内容不足: size=%d choices=%d" % [dialogue.size(), choice_entries])

func _test_scoring_system():
	_start_test("评分系统-5维度")
	GameManager.skills = {"cognitive": 0, "behavioral": 0, "empathic": 0}
	ScoringSystem.start_new_session()
	ScoringSystem.log_choice("t1", "empathy", 4, "共情优秀")
	ScoringSystem.log_choice("t2", "active_listening", 3, "倾听良好")
	ScoringSystem.log_choice("t3", "socratic_questioning", 5, "提问极佳")
	ScoringSystem.log_choice("t4", "cognitive_restructuring", 2, "重构一般")
	ScoringSystem.log_choice("t5", "rapport", -2, "关系受损")
	
	var result: Dictionary = ScoringSystem.evaluate_session()
	var s: Dictionary = result.scores
	
	if s.get("empathy") == 4 and s.get("socratic_questioning") == 5 and result.good_choices.size() >= 3:
		_pass("总分: %d, 评级: %s, 好评: %d, 反馈: %s" % [result.total, result.grade, result.good_choices.size(), result.feedback])
	else:
		_fail("评分异常: %s" % str(s))

func _test_game_manager_full_flow():
	_start_test("完整游戏流程(3次治疗+解锁)")
	GameManager.unlocked_patients = ["lin_xiaoyu"]
	GameManager.completed_sessions = {}
	GameManager.patient_scores = {}
	GameManager.total_score = 0
	GameManager.therapist_level = 1
	GameManager.patient_bond = {}
	GameManager.patient_emotion_states = {}
	GameManager.skills = {"cognitive": 0, "behavioral": 0, "empathic": 0}
	GameManager.therapy_journal.clear()
	GameManager.achievements = {}
	GameManager.tutorials_shown = {}
	GameManager.total_sessions_count = 0
	GameManager.s_grade_count = 0
	GameManager.skill_points = 0
	GameManager.completed_chapters.clear()
	GameManager.current_chapter = "chapter_1"
	
	if GameManager.is_patient_unlocked("zhang_hao"):
		_fail("初始状态张浩不应解锁")
		return
	
	var scores := [0, 0, 0]
	for i in range(3):
		var p = _make_patient("lin_xiaoyu")
		var dialogue: Array = p._build_session_dialogue(i + 1)
		
		ScoringSystem.start_new_session()
		GameManager.start_session("lin_xiaoyu")
		for entry in dialogue:
			if entry.has("choices"):
				var best := {}
				var best_pts := -100
				for c in entry.choices:
					if c.get("score_points", 0) > best_pts:
						best_pts = c.score_points
						best = c
				if best.size() > 0:
					ScoringSystem.log_choice(best.id, best.score_category, best.score_points, best.feedback)
		var result: Dictionary = ScoringSystem.evaluate_session()
		scores[i] = result.total
		GameManager.end_session(result)
	
	var progress: int = GameManager.get_patient_progress("lin_xiaoyu")
	var zhang_unlocked: bool = GameManager.is_patient_unlocked("zhang_hao")
	
	if progress != 3:
		_fail("进度: 期望3, 实际%d" % progress)
		return
	if not zhang_unlocked:
		_fail("3次后张浩未解锁")
		return
	
	_pass("3次治疗完成, 进度=%d, 总分=%d, 等级=%d, 张浩解锁=%s" % [
		progress, GameManager.total_score, GameManager.therapist_level, zhang_unlocked])

func _test_trust_system():
	_start_test("信任/羁绊系统")
	GameManager.patient_bond = {}
	
	var bond: int = GameManager.get_bond("lin_xiaoyu")
	if bond != 30:
		_fail("初始信任: 期望30, 实际%d" % bond)
		return
	
	GameManager.modify_bond("lin_xiaoyu", 10)
	bond = GameManager.get_bond("lin_xiaoyu")
	if bond != 40:
		_fail("+10后: 期望40, 实际%d" % bond)
		return
	
	GameManager.modify_bond("lin_xiaoyu", -5)
	bond = GameManager.get_bond("lin_xiaoyu")
	if bond != 35:
		_fail("-5后: 期望35, 实际%d" % bond)
		return
	
	GameManager.modify_bond("lin_xiaoyu", 200)
	bond = GameManager.get_bond("lin_xiaoyu")
	if bond != 100:
		_fail("上界: 期望100, 实际%d" % bond)
		return
	
	GameManager.modify_bond("lin_xiaoyu", -200)
	bond = GameManager.get_bond("lin_xiaoyu")
	if bond != 0:
		_fail("下界: 期望0, 实际%d" % bond)
		return
	
	var level: String = GameManager.get_bond_level("lin_xiaoyu")
	if level != "closed":
		_fail("0信任等级: 期望closed, 实际%s" % level)
		return
	
	GameManager.patient_bond["lin_xiaoyu"] = 65
	level = GameManager.get_bond_level("lin_xiaoyu")
	if level != "open":
		_fail("65信任等级: 期望open, 实际%s" % level)
		return
	
	_pass("信任增减/上下界/等级 全部正确")

func _test_emotion_state_machine():
	_start_test("情绪状态机")
	GameManager.patient_emotion_states = {}
	GameManager.patient_bond = {"lin_xiaoyu": 55}
	
	var state: String = GameManager.get_emotion_state("lin_xiaoyu", "depression")
	if state != "active":
		_fail("初始状态: 期望active, 实际%s" % state)
		return
	
	GameManager.set_emotion_state("lin_xiaoyu", "depression", "recovering")
	state = GameManager.get_emotion_state("lin_xiaoyu", "depression")
	if state != "recovering":
		_fail("恢复中: 期望recovering, 实际%s" % state)
		return
	
	GameManager.set_emotion_state("lin_xiaoyu", "depression", "resilient")
	state = GameManager.get_emotion_state("lin_xiaoyu", "depression")
	if state != "resilient":
		_fail("有韧性: 期望resilient, 实际%s" % state)
		return
	
	var summary: String = GameManager.get_patient_emotion_summary("lin_xiaoyu")
	if not "resilient" in summary:
		_fail("摘要: 期望包含resilient, 实际%s" % summary)
		return
	
	_pass("状态转换: active→recovering→resilient, 摘要=%s" % summary)

func _test_skill_tree():
	_start_test("CBT技能树")
	GameManager.skills = {"cognitive": 0, "behavioral": 0, "empathic": 0}
	GameManager.skill_points = 3
	
	var ok: bool = SkillTree.upgrade_skill("cognitive")
	if not ok or GameManager.skills["cognitive"] != 1:
		_fail("升级认知: 失败")
		return
	
	if GameManager.skill_points != 2:
		_fail("技能点: 期望2, 实际%d" % GameManager.skill_points)
		return
	
	var lines: Array[String] = SkillTree.get_all_lines()
	if lines.size() != 3:
		_fail("技能线: 期望3, 实际%d" % lines.size())
		return
	
	var mult: float = SkillTree.get_score_multiplier("socratic_questioning")
	if mult != 1.0:
		_fail("Lv0苏格拉底倍率: 期望1.0, 实际%f" % mult)
		return
	
	GameManager.skills["cognitive"] = 2
	mult = SkillTree.get_score_multiplier("socratic_questioning")
	if mult != 1.2:
		_fail("Lv2苏格拉底倍率: 期望1.2, 实际%f" % mult)
		return
	
	var bonus: int = SkillTree.get_bond_bonus()
	if bonus != 0:
		_fail("Lv0共情奖励: 期望0, 实际%d" % bonus)
		return
	
	GameManager.skills["empathic"] = 2
	bonus = SkillTree.get_bond_bonus()
	if bonus != 2:
		_fail("Lv2共情奖励: 期望2, 实际%d" % bonus)
		return
	
	_pass("技能升级/倍率/奖励 全部正确")

func _test_achievements():
	_start_test("成就徽章系统")
	GameManager.achievements = {}
	GameManager.total_sessions_count = 0
	GameManager.s_grade_count = 0
	
	GameManager._check_achievement("first_session")
	if not GameManager.achievements.get("first_session", false):
		_fail("first_session未解锁")
		return
	
	GameManager._check_achievement("first_session")
	var count := 0
	for v in GameManager.achievements.values():
		if v: count += 1
	if count != 1:
		_fail("重复解锁: 期望1个, 实际%d个" % count)
		return
	
	GameManager.total_sessions_count = 5
	GameManager._check_achievements()
	if not GameManager.achievements.get("five_sessions", false):
		_fail("five_sessions未解锁")
		return
	
	_pass("成就解锁/去重/条件触发 全部正确")

func _test_journal():
	_start_test("治疗日记")
	GameManager.therapy_journal.clear()
	
	var entry := {
		"patient_id": "lin_xiaoyu",
		"session": 1,
		"score_total": 7,
		"grade": "C",
		"bond_after": 35,
		"emotions": {"depression": "active"},
	}
	GameManager.therapy_journal.append(entry)
	
	if GameManager.therapy_journal.size() != 1:
		_fail("日记条目: 期望1, 实际%d" % GameManager.therapy_journal.size())
		return
	
	var saved_entry: Dictionary = GameManager.therapy_journal[0]
	if saved_entry.get("patient_id") != "lin_xiaoyu":
		_fail("日记内容: patient_id不匹配")
		return
	if saved_entry.get("grade") != "C":
		_fail("日记内容: grade不匹配")
		return
	
	_pass("日记记录/检索 正确")

func _test_battle_engine_init():
	_start_test("战斗引擎-患者初始化")
	BattleEngine.reset_patient("test_patient")
	BattleEngine.init_patient("test_patient", {
		"initial_state": 0,
		"alliance": 20,
		"anxiety": 50,
		"depression": 60,
		"defensiveness": 40,
		"insight": 10,
		"avoidance": 30,
		"hope": 20,
		"hidden_schemas": ["我不够好", "别人会伤害我"],
	})
	
	var data: Dictionary = BattleEngine.get_patient_data("test_patient")
	if data.is_empty():
		_fail("数据为空")
		return
	
	if BattleEngine.get_state("test_patient") != 0:
		_fail("初始状态: 期望0(GUARDED), 实际%d" % BattleEngine.get_state("test_patient"))
		return
	
	if BattleEngine.get_alliance("test_patient") != 20:
		_fail("alliance: 期望20, 实际%d" % BattleEngine.get_alliance("test_patient"))
		return
	
	var schemas: Array = BattleEngine.get_hidden_schemas("test_patient")
	if schemas.size() != 2:
		_fail("隐藏schema: 期望2, 实际%d" % schemas.size())
		return
	
	BattleEngine.reset_patient("test_patient")
	_pass("初始化/状态/alliance/schema 全部正确")

func _test_battle_engine_effectiveness():
	_start_test("战斗引擎-属性克制")
	BattleEngine.reset_patient("eff_test")
	BattleEngine.init_patient("eff_test", {"initial_state": 0, "alliance": 20})
	
	var r1: Dictionary = BattleEngine.apply_skill("eff_test", "reflection", 3)
	if r1.get("actual_points", 0) <= 3:
		_fail("GUARDED+reflection应放大: 实际%d" % r1.get("actual_points", 0))
		return
	
	BattleEngine.reset_patient("eff_test")
	BattleEngine.init_patient("eff_test", {"initial_state": 0, "alliance": 20})
	
	var r2: Dictionary = BattleEngine.apply_skill("eff_test", "cognitive_restructuring", 3)
	if r2.get("actual_points", 0) >= 0:
		_fail("GUARDED+cognitive应反效果: 实际%d" % r2.get("actual_points", 0))
		return
	
	var eff_label: String = r2.get("effectiveness_label", "")
	if eff_label == "":
		_fail("缺少效果标签")
		return
	
	BattleEngine.reset_patient("eff_test")
	_pass("克制效果: reflection放大=%d, cognitive反效果=%d, 标签=%s" % [r1.actual_points, r2.actual_points, eff_label])

func _test_battle_engine_state_transition():
	_start_test("战斗引擎-状态转换")
	BattleEngine.reset_patient("trans_test")
	BattleEngine.init_patient("trans_test", {"initial_state": 0, "alliance": 20, "defensiveness": 40, "insight": 10})
	
	if BattleEngine.get_state("trans_test") != 0:
		_fail("初始应为GUARDED(0)")
		return
	
	BattleEngine.apply_skill("trans_test", "reflection", 3)
	BattleEngine.apply_skill("trans_test", "validation", 3)
	BattleEngine.apply_skill("trans_test", "empathy", 3)
	
	var state_name: String = BattleEngine.get_state_name("trans_test")
	if state_name == "防御":
		_fail("多次好技能后应离开GUARDED, 仍为%s" % state_name)
		return
	
	BattleEngine.reset_patient("trans_test")
	BattleEngine.init_patient("trans_test", {"initial_state": 0, "alliance": 20})
	
	BattleEngine.apply_skill("trans_test", "cognitive_restructuring", 3)
	var state2: String = BattleEngine.get_state_name("trans_test")
	if state2 != "抗拒":
		_fail("GUARDED+cognitive应转RESISTANT, 实际%s" % state2)
		return
	
	BattleEngine.reset_patient("trans_test")
	_pass("GUARDED→%s, 反效果→RESISTANT" % state_name)

func _test_battle_engine_schema_discovery():
	_start_test("战斗引擎-Schema发现")
	BattleEngine.reset_patient("schema_test")
	BattleEngine.init_patient("schema_test", {
		"initial_state": 0,
		"alliance": 50,
		"hidden_schemas": ["我不值得被爱"],
	})
	
	var discovered := false
	for i in range(20):
		BattleEngine.apply_skill("schema_test", "reflection", 3)
		if BattleEngine.get_discovered_schemas("schema_test").size() > 0:
			discovered = true
			break
	
	if not discovered:
		_fail("20次高效果技能后未发现schema")
		return
	
	var disc: Array = BattleEngine.get_discovered_schemas("schema_test")
	BattleEngine.reset_patient("schema_test")
	_pass("发现schema: %s" % str(disc))

func _cleanup():
	for p in _patients:
		if is_instance_valid(p):
			p.queue_free()
	_patients.clear()

func _start_test(name: String):
	_current_test = name

func _pass(msg: String):
	_test_results.append("  PASS: [%s] %s" % [_current_test, msg])
	print("  [PASS] %s: %s" % [_current_test, msg])

func _fail(msg: String):
	_test_results.append("  FAIL: [%s] %s" % [_current_test, msg])
	push_error("  [FAIL] %s: %s" % [_current_test, msg])

func _wait(seconds: float):
	await get_tree().create_timer(seconds).timeout

func _print_results():
	var pc := 0
	var fc := 0
	for r in _test_results:
		if r.begins_with("  PASS"): pc += 1
		else: fc += 1
	print("\n========== TEST RESULTS ==========")
	for r in _test_results:
		print(r)
	print("\n  Total: %d | Passed: %d | Failed: %d" % [pc + fc, pc, fc])
	if fc == 0:
		print("  >>> ALL TESTS PASSED! <<<")
	else:
		print("  >>> %d TEST(S) FAILED <<<" % fc)
	print("==================================\n")
