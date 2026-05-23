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
		d.append({"speaker": "小李", "text": "欢迎来到心理治疗中心！我是前台小李，有问题随时来找我。"})
		d.append({"speaker": "小李", "text": "林小雨在左上方的诊室A等你。走近她，按空格键开始治疗吧！"})
		d.append({"speaker": "小李", "text": "小提示：倾听和共情是打开患者心扉的关键，不要急着给建议哦。"})
		DialogueManager.start_dialogue(d)
		return
	
	if is_stuck != "":
		_build_stuck_dialogue(d, is_stuck)
		DialogueManager.start_dialogue(d, _execute_pending)
		return
	
	_build_normal_dialogue(d)
	DialogueManager.start_dialogue(d, _execute_pending)

func _build_stuck_dialogue(d: Array[Dictionary], stuck_reason: String):
	d.append({"speaker": "小李", "text": "看起来你遇到了一些困难..."})
	d.append({"speaker": "小李", "text": stuck_reason})
	d.append({"speaker": "小李", "text": "你需要什么帮助？"})
	d.append({
		"choices": [
			{"text": "给我一些治疗技巧", "next": "recep_tips"},
			{"text": "重置当前患者的治疗记录", "next": "recep_rp_ask"},
			{"text": "重置全部游戏进度", "next": "recep_ra_ask"},
			{"text": "不用了，我再试试", "next": "recep_go"},
		]
	})
	d.append({"label": "recep_tips", "speaker": "小李", "text": _get_therapy_tips()})
	d.append({"label": "recep_rp_ask", "speaker": "小李", "text": "确定要重置当前患者的治疗记录吗？你会从头开始治疗这位患者。"})
	d.append({"choices": [
		{"text": "确认重置当前患者", "next": "recep_rp_ok"},
		{"text": "算了", "next": "recep_rp_no"},
	]})
	d.append({"label": "recep_rp_ok", "speaker": "小李", "text": "好的，治疗记录已清除。去重新找患者开始治疗吧！"})
	d.append({"label": "recep_rp_no", "speaker": "小李", "text": "没问题，继续加油！"})
	d.append({"label": "recep_ra_ask", "speaker": "小李", "text": "确定要重置全部进度吗？所有治疗记录、技能和成就都会清零！"})
	d.append({"choices": [
		{"text": "确认重置全部", "next": "recep_ra_ok"},
		{"text": "算了", "next": "recep_ra_no"},
	]})
	d.append({"label": "recep_ra_ok", "speaker": "小李", "text": "全部进度已清除。欢迎重新开始治疗师之旅！"})
	d.append({"label": "recep_ra_no", "speaker": "小李", "text": "好的，继续加油！"})
	d.append({"label": "recep_go", "speaker": "小李", "text": "好的！记住：先共情倾听，再引导反思。你一定可以的！"})

func _build_normal_dialogue(d: Array[Dictionary]):
	d.append({"speaker": "小李", "text": _get_progress_summary()})
	d.append({"speaker": "小李", "text": _get_hint()})
	d.append({
		"choices": [
			{"text": "当前任务是什么？", "next": "recep_task"},
			{"text": "给我一些治疗建议", "next": "recep_advice"},
			{"text": "重置全部进度", "next": "recep_full_ask"},
			{"text": "谢谢，我继续去了", "next": "recep_bye"},
		]
	})
	d.append({"label": "recep_task", "speaker": "小李", "text": _get_task_detail()})
	d.append({"label": "recep_advice", "speaker": "小李", "text": _get_therapy_tips()})
	d.append({"label": "recep_full_ask", "speaker": "小李", "text": "确定要重置全部进度吗？所有数据都会清零！"})
	d.append({"choices": [
		{"text": "确认重置", "next": "recep_full_ok"},
		{"text": "算了", "next": "recep_full_no"},
	]})
	d.append({"label": "recep_full_ok", "speaker": "小李", "text": "全部进度已清除。"})
	d.append({"label": "recep_full_no", "speaker": "小李", "text": "好的，继续加油！"})
	d.append({"label": "recep_bye", "speaker": "小李", "text": "加油！有问题随时来找我。"})

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
		return "当前章节技能等级不足：\n%s\n按 K 键升级技能树。" % missing
	
	if progress >= needed:
		var status: String = GameManager.get_chapter_status_text()
		if status != "":
			return "你已做了 %d 次治疗，但%s。" % [progress, status]
	
	if progress >= needed + 2:
		return "你已经做了很多次治疗，但章节仍未通过。可能需要调整策略。"
	
	return ""

func _get_progress_summary() -> String:
	var ch_title: String = GameManager.get_chapter_def(GameManager.current_chapter).get("title", "")
	return "治疗师 Lv.%d | %s | 已完成 %d 次治疗 | 总分 %d | 技能点 %d" % [
		GameManager.therapist_level, ch_title, GameManager.total_sessions_count,
		GameManager.total_score, GameManager.skill_points]

func _get_hint() -> String:
	var ch_def: Dictionary = GameManager.get_chapter_def(GameManager.current_chapter)
	if ch_def.is_empty():
		return "你已经完成了所有章节！"
	var pid: String = ch_def.get("patient_id", "")
	var progress: int = GameManager.completed_sessions.get(pid, 0)
	var needed: int = ch_def.get("required_sessions", 3)
	var patient_names := {"lin_xiaoyu": "林小雨", "zhang_hao": "张浩", "wang_mei": "王美"}
	var pname: String = patient_names.get(pid, "")
	if pname == "":
		return "你已经走到最后了，加油！"
	if progress == 0:
		return "去找%s开始治疗吧，她在%s。" % [pname, _get_room_hint(pid)]
	if progress < needed:
		return "继续和%s对话，还剩 %d 次治疗。" % [pname, needed - progress]
	return "%s的治疗次数已够。如果评级不够，可以继续追加治疗。" % pname

func _get_room_hint(pid: String) -> String:
	match pid:
		"lin_xiaoyu": return "左上方诊室A"
		"zhang_hao": return "右上方诊室B"
		"wang_mei": return "左下方"
		_: return "诊室"

func _get_task_detail() -> String:
	var ch_def: Dictionary = GameManager.get_chapter_def(GameManager.current_chapter)
	if ch_def.is_empty():
		return "所有章节已完成！"
	var pid: String = ch_def.get("patient_id", "")
	var needed: int = ch_def.get("required_sessions", 3)
	var progress: int = GameManager.completed_sessions.get(pid, 0)
	var min_grade: String = ch_def.get("min_grade", "D")
	var patient_names := {"lin_xiaoyu": "林小雨", "zhang_hao": "张浩", "wang_mei": "王美"}
	var pname: String = patient_names.get(pid, "")
	var text := "当前章节：%s\n" % ch_def.get("title", "")
	text += "目标患者：%s\n" % pname
	text += "治疗进度：%d / %d 次\n" % [progress, needed]
	text += "评级要求：最低 %s 级" % min_grade
	if not GameManager.meets_skill_requirements(GameManager.current_chapter):
		text += "\n\n注意：技能等级不足！按K键升级技能树。"
	return text

func _get_therapy_tips() -> String:
	var tips := {
		"chapter_1": "林小雨有抑郁倾向，常常'非黑即白'地看问题。\n\n要点：\n1. 先倾听和共情，让她感到被理解\n2. 用提问引导她检视消极想法的证据\n3. 不要直接否定感受——'别这么想'会适得其反\n4. 她防御时用反映和确认来'破防'",
		"chapter_2": "张浩的问题是灾难化思维，总往最坏处想。\n\n要点：\n1. 用苏格拉底式提问检视担忧的现实基础\n2. 引导回忆'担心的结果有多少真正发生了'\n3. 认知链分析可系统性解构灾难化\n4. 不要说'想太多没用'——他不被理解会更焦虑",
		"chapter_3": "王美倾向个人化，什么错都怪自己。\n\n要点：\n1. 帮她看到事情的多因性\n2. 双标准技术很有效：'如果是同事遇到呢？'\n3. 高级行为实验可用数据挑战信念\n4. 不要简单安慰'别怪自己'——要引导她自己发现",
	}
	return tips.get(GameManager.current_chapter,
		"通用治疗技巧：\n\n1. 先共情倾听，不要急着给建议\n2. 用提问引导患者自己发现问题\n3. 患者防御时 → 用反映/确认技巧\n4. 患者反思时 → 用认知重构深入\n5. 按K键升级技能树，解锁高级选项")
