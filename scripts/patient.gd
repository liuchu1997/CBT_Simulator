extends "res://scripts/npc_base.gd"

@export var patient_id: String = "lin_xiaoyu"
@export var max_sessions: int = 5

var emotion := {
	"depression": 0,
	"anxiety": 0,
	"anger": 0,
	"hope": 0,
	"trust": 30,
}
var cognitive_distortions: Array[String] = []
var current_expression: String = "sad"

func _ready():
	super._ready()
	_init_patient_data()
	if not GameManager.is_patient_unlocked(patient_id):
		visible = false
	if GameManager:
		GameManager.patient_unlocked.connect(_on_patient_unlocked_local)

func _on_patient_unlocked_local(unlocked_pid: String):
	if unlocked_pid == patient_id:
		visible = true

func _ensure_battle_data():
	if not BattleEngine:
		return
	if BattleEngine.get_patient_data(patient_id).size() > 0:
		return
	match patient_id:
		"lin_xiaoyu":
			_init_battle_data("lin_xiaoyu", {
				"initial_state": 0,
				"alliance": 20,
				"anxiety": 45,
				"depression": 70,
				"defensiveness": 40,
				"insight": 10,
				"avoidance": 30,
				"hope": 25,
				"hidden_schemas": ["我不值得被爱", "我必须完美才能被接受", "如果我犯错，所有人都会离开我"],
			})
		"zhang_hao":
			_init_battle_data("zhang_hao", {
				"initial_state": 0,
				"alliance": 15,
				"anxiety": 80,
				"depression": 30,
				"defensiveness": 50,
				"insight": 5,
				"avoidance": 20,
				"hope": 40,
				"hidden_schemas": ["世界是危险的", "我必须控制一切才能安全", "失控意味着死亡"],
			})
		"wang_mei":
			_init_battle_data("wang_mei", {
				"initial_state": 0,
				"alliance": 15,
				"anxiety": 75,
				"depression": 50,
				"defensiveness": 35,
				"insight": 8,
				"avoidance": 40,
				"hope": 30,
				"hidden_schemas": ["都是我的错", "如果我让别人不高兴，就是我不好", "我必须取悦所有人"],
			})

func _init_patient_data():
	match patient_id:
		"lin_xiaoyu":
			npc_name = "林小雨"
			emotion = {"depression": 70, "anxiety": 45, "anger": 20, "hope": 25, "trust": 30}
			cognitive_distortions = ["非黑即白", "过度概括", "心理过滤"]
			_init_battle_data("lin_xiaoyu", {
				"initial_state": 0,
				"alliance": 20,
				"anxiety": 45,
				"depression": 70,
				"defensiveness": 40,
				"insight": 10,
				"avoidance": 30,
				"hope": 25,
				"hidden_schemas": ["我不值得被爱", "我必须完美才能被接受", "如果我犯错，所有人都会离开我"],
			})
		"zhang_hao":
			npc_name = "张浩"
			emotion = {"depression": 30, "anxiety": 80, "anger": 40, "hope": 40, "trust": 25}
			cognitive_distortions = ["灾难化", "读心术", "过度控制"]
			_init_battle_data("zhang_hao", {
				"initial_state": 0,
				"alliance": 15,
				"anxiety": 80,
				"depression": 30,
				"defensiveness": 50,
				"insight": 5,
				"avoidance": 20,
				"hope": 40,
				"hidden_schemas": ["世界是危险的", "我必须控制一切才能安全", "失控意味着死亡"],
			})
		"wang_mei":
			npc_name = "王美"
			emotion = {"depression": 50, "anxiety": 75, "anger": 15, "hope": 30, "trust": 20}
			cognitive_distortions = ["个人化", "放大化", "贴标签"]
			_init_battle_data("wang_mei", {
				"initial_state": 0,
				"alliance": 15,
				"anxiety": 75,
				"depression": 50,
				"defensiveness": 35,
				"insight": 8,
				"avoidance": 40,
				"hope": 30,
				"hidden_schemas": ["都是我的错", "如果我让别人不高兴，就是我不好", "我必须取悦所有人"],
			})

func _init_battle_data(pid: String, config: Dictionary):
	if not BattleEngine:
		return
	if BattleEngine.get_patient_data(pid).size() > 0:
		return
	BattleEngine.init_patient(pid, config)

func on_interact():
	if not is_interactable:
		return
	_face_player()
	
	if DialogueManager.is_active():
		return
	
	if not GameManager.is_patient_unlocked(patient_id):
		_show_locked_dialogue()
		return
	
	var chapter_id := _get_chapter_id()
	if chapter_id != "" and not GameManager.meets_skill_requirements(chapter_id):
		_show_skill_requirement_dialogue(chapter_id)
		return
	
	if chapter_id != "" and GameManager.is_chapter_completed(chapter_id):
		_show_completion_dialogue()
		return
	
	var progress := GameManager.get_patient_progress(patient_id)
	if progress >= max_sessions:
		if chapter_id != "" and GameManager.current_chapter == chapter_id:
			if not GameManager.is_chapter_completed(chapter_id):
				_show_retry_dialogue()
				return
		_show_completion_dialogue()
	else:
		_ensure_battle_data()
		_start_session()

func _get_chapter_id() -> String:
	match patient_id:
		"lin_xiaoyu": return "chapter_1"
		"zhang_hao": return "chapter_2"
		"wang_mei": return "chapter_3"
		_: return ""

func _show_locked_dialogue():
	var d: Array[Dictionary] = []
	d.append({"speaker": "系统", "text": "这个患者还没有解锁。完成当前章节以解锁新患者。"})
	DialogueManager.start_dialogue(d)

func _show_skill_requirement_dialogue(chapter_id: String):
	var missing: String = GameManager.get_missing_skills_text(chapter_id)
	var chapter_title: String = GameManager.get_chapter_def(chapter_id).get("title", "")
	var d: Array[Dictionary] = []
	d.append({"speaker": "系统", "text": "【%s】需要以下技能才能开始：" % chapter_title})
	d.append({"speaker": "系统", "text": "%s\n\n按 K 键打开技能树升级技能。" % missing})
	DialogueManager.start_dialogue(d)

func _start_session():
	var session_num := GameManager.get_patient_progress(patient_id) + 1
	ScoringSystem.start_new_session()
	GameManager.start_session(patient_id)
	GameManager.check_bond_decay()
	
	if RoomManager:
		RoomManager.change_to_patient_room(patient_id)
	
	var dialogue := _build_session_dialogue(session_num)
	
	if session_num > 1 and GameManager.has_pending_homework(patient_id):
		dialogue = _build_homework_review(patient_id, dialogue)
	
	if session_num == 1:
		dialogue = _build_first_session_intro(dialogue)
	
	DialogueManager.start_dialogue(dialogue, _on_session_ended)

func _build_first_session_intro(dialogue: Array[Dictionary]) -> Array[Dictionary]:
	var intro: Array[Dictionary] = []
	intro.append({"speaker": "你", "text": "你好，我是你的治疗师。在开始之前，我想先了解一下你的情况。"})
	intro.append({"speaker": "你", "text": "你能告诉我，最近最困扰你的是什么吗？"})
	intro.append({"speaker": npc_name, "text": _get_initial_complaint()})
	intro.append({"speaker": "你", "text": "谢谢你愿意分享这些。在接下来的治疗中，我们会一起探索你的思维模式，找到应对的方法。"})
	intro.append({"speaker": npc_name, "text": "...好的，我试试。"})
	intro.append_array(dialogue)
	return intro

func _get_initial_complaint() -> String:
	match patient_id:
		"lin_xiaoyu": return "我觉得自己什么都做不好...工作上出了问题，领导批评了我，我就觉得自己是个废物。每天都很低落，什么都不想做。"
		"zhang_hao": return "我每天都在担心各种事情，停不下来。工作、健康、家人...脑子里总是往最坏的方向想，非常焦虑。"
		"wang_mei": return "我总觉得什么都是我的错。不管出什么事，我都会先怪自己。我知道这样不好，但控制不住。"
		_: return "最近感觉不太好..."

func _build_homework_review(pid: String, dialogue: Array[Dictionary]) -> Array[Dictionary]:
	var hw: Dictionary = GameManager.get_homework(pid)
	if hw.is_empty():
		return dialogue
	var review: Array[Dictionary] = []
	review.append({"speaker": "你", "text": "上次我给你布置了一个练习——%s。你试过了吗？" % hw.get("task", "")})
	review.append({"speaker": npc_name, "text": _get_homework_response(hw)})
	GameManager.complete_homework(pid)
	review.append_array(dialogue)
	return review

func _get_homework_response(hw: Dictionary) -> String:
	var detail: String = hw.get("detail", "")
	if detail.find("日记") >= 0 or detail.find("记录") >= 0:
		return _bond_text(
			"我试了一下...虽然有时候会忘记，但我确实注意到一些自动冒出来的消极想法。",
			"我每天都在记！发现了很多自己平时没注意到的思维模式。",
			"这个练习真的很有帮助。我现在能很快发现自己在进行认知扭曲了。"
		)
	if detail.find("放松") >= 0 or detail.find("呼吸") >= 0:
		return _bond_text(
			"试了几次深呼吸，确实焦虑的时候能稍微平静一点。",
			"我现在每天睡前都做放松练习，睡眠质量好了不少。",
			"放松技巧已经成为我的日常习惯了，感觉比以前平静很多。"
		)
	if detail.find("活动") >= 0 or detail.find("散步") >= 0:
		return _bond_text(
			"我去散了一次步...虽然不太想出门，但走完后心情确实好了一些。",
			"这周我每天都出去走了走，发现运动真的能改善心情。",
			"我现在很享受每天的活动时间，它已经成为我生活的一部分了。"
		)
	return _bond_text(
		"我试了一下...虽然不太确定做得对不对。",
		"我认真做了练习，感觉有一些帮助。",
		"练习效果很好，我会继续坚持的。"
	)

func _assign_session_homework(session_num: int):
	match patient_id:
		"lin_xiaoyu":
			if session_num == 1:
				GameManager.assign_homework(patient_id, "情绪日记", "每天晚上花5分钟记录今天冒出来的消极想法，不用分析，只记录。")
			elif session_num == 2:
				GameManager.assign_homework(patient_id, "行为激活", "本周尝试做一件让自己有成就感的小事，比如散步15分钟或整理房间。")
		"zhang_hao":
			if session_num == 1:
				GameManager.assign_homework(patient_id, "焦虑记录", "每次焦虑时，写下：1.我在担心什么？2.最坏的结果是什么？3.实际发生的概率有多大？")
			elif session_num == 2:
				GameManager.assign_homework(patient_id, "放松练习", "每天练习一次4-7-8呼吸法：吸气4秒→屏息7秒→呼气8秒，重复3次。")
		"wang_mei":
			if session_num == 1:
				GameManager.assign_homework(patient_id, "双标准练习", "每次怪自己时，问：如果是好朋友遇到同样的情况，我会怪她吗？")
			elif session_num == 2:
				GameManager.assign_homework(patient_id, "责任饼图", "遇到问题时，画一个'责任饼图'，列出所有相关因素和各自的责任比例。")

func _on_session_ended():
	var result := ScoringSystem.evaluate_session()
	result["patient_name"] = npc_name
	result["session_num"] = GameManager.current_session_num
	GameManager.end_session(result)
	_update_expression()
	CbtTutorial._on_trigger("first_score")
	_assign_session_homework(GameManager.current_session_num)
	CbtTutorial._on_trigger("homework_assigned")
	
	if GameManager.current_session_num == 1:
		CbtTutorial._on_trigger("cognitive_triangle")
	
	if RoomManager:
		RoomManager.return_to_lobby()
	
	await get_tree().process_frame
	var report_ui := get_tree().get_first_node_in_group("score_report")
	if report_ui and report_ui.has_method("show_report"):
		report_ui.show_report(result, _on_report_closed)

func _on_report_closed():
	if GameManager.is_chapter_completed(GameManager.current_chapter):
		await get_tree().create_timer(0.05).timeout
		var cc_ui := get_tree().get_first_node_in_group("chapter_complete")
		if cc_ui and cc_ui.has_method("show_chapter_complete"):
			cc_ui.show_chapter_complete()

func _build_session_dialogue(session_num: int) -> Array[Dictionary]:
	match patient_id:
		"lin_xiaoyu":
			return _lin_dialogue(session_num)
		"zhang_hao":
			return _zhang_dialogue(session_num)
		"wang_mei":
			return _wang_dialogue(session_num)
		_:
			return [{"speaker": npc_name, "text": "...你好。"}]

func _bond_text(low: String, mid: String, high: String) -> String:
	var b := GameManager.get_bond(patient_id)
	if b >= 60: return high
	if b >= 40: return mid
	return low

func _emotion_prefix() -> String:
	if not BattleEngine:
		return ""
	var data: Dictionary = BattleEngine.get_patient_data(patient_id)
	if data.is_empty():
		return ""
	var state_name: String = BattleEngine.get_state_name(patient_id)
	match state_name:
		"防御": return "（双臂交叉，眼神回避）"
		"试探": return "（犹豫地看了你一眼）"
		"敞开心扉": return "（看起来放松了一些）"
		"情绪泛滥": return "（眼眶发红，声音颤抖）"
		"抗拒": return "（明显不配合，身体后仰）"
		"反思": return "（若有所思地点点头）"
		"领悟": return "（眼睛一亮，似乎想通了什么）"
		_: return ""

func _lin_dialogue(s: int) -> Array[Dictionary]:
	var d: Array[Dictionary] = []
	var prefix := _emotion_prefix()
	match s:
		1:
			d.append({"speaker": "林小雨", "text": "%s...你好。是你要给我做咨询吗？" % prefix})
			d.append({"speaker": "林小雨", "text": "说实话...我觉得来这可能也没什么用。我什么都做不好，咨询又能改变什么呢..."})
			d.append({
				"choices": [
					{"text": "你能告诉我，是什么让你有这种感觉的吗？", "score_category": "active_listening", "score_points": 3, "feedback": "开放式问题引导患者表达", "id": "lin_s1_open", "next": "lin_s1_resp1_open"},
					{"text": "我理解你现在的感受。来到这里需要很大的勇气。", "score_category": "empathy", "score_points": 3, "feedback": "共情患者的感受，肯定她的勇气", "id": "lin_s1_empathy", "next": "lin_s1_resp1_empathy"},
					{"text": "别这么想，你一定有很多优点的！", "score_category": "rapport", "score_points": -1, "feedback": "过早安慰，未充分倾听", "id": "lin_s1_dismiss", "next": "lin_s1_resp1_dismiss"},
					{"text": "这种想法是不合理的，你应该更积极地看问题。", "score_category": "cognitive_restructuring", "score_points": -3, "feedback": "直接否定患者感受，缺乏共情", "id": "lin_s1_confront", "next": "lin_s1_resp1_confront"},
				]
			})
			d.append({"label": "lin_s1_resp1_open", "speaker": "林小雨", "text": "...你真的想听？好久没人问我了...其实最近工作上的项目出了问题，领导在会上批评了我..."})
			d.append({"label": "lin_s1_resp1_empathy", "speaker": "林小雨", "text": "...谢谢你能理解。其实...最近工作上的项目出了问题，领导在会上批评了我..."})
			d.append({"label": "lin_s1_resp1_dismiss", "speaker": "林小雨", "text": "（勉强笑了笑）...你这么说让我有点不自在。其实最近项目出了问题，领导批评了我..."})
			d.append({"label": "lin_s1_resp1_confront", "speaker": "林小雨", "text": "（身体缩了一下）...你这样说让我更难过了。我只是想被听到而已..."})
			d.append({"speaker": "林小雨", "text": "从那以后我就一直觉得，我是整个团队最差的人。我肯定要被裁掉了..."})
			d.append({
				"choices": [
					{"text": "你说是'整个团队最差的'——有什么具体的证据吗？", "score_category": "socratic_questioning", "score_points": 4, "feedback": "苏格拉底式提问，引导检视证据", "id": "lin_s1_socratic", "next": "lin_s1_resp2_socratic"},
					{"text": "被领导批评确实很难受。你觉得'最差'这个词准确描述了情况吗？", "score_category": "cognitive_restructuring", "score_points": 3, "feedback": "温和地引导患者审视认知扭曲", "id": "lin_s1_reframe", "next": "lin_s1_resp2_reframe"},
					{"text": "我觉得你太悲观了，一次批评不代表什么。", "score_category": "empathy", "score_points": -2, "feedback": "否定感受，未能深入探索", "id": "lin_s1_minimize", "next": "lin_s1_resp2_minimize"},
				]
			})
			d.append({"label": "lin_s1_resp2_socratic", "speaker": "林小雨", "text": "...证据？嗯...其实上次我的代码审核分数还挺高的...但我就是控制不住这么想..."})
			d.append({"label": "lin_s1_resp2_reframe", "speaker": "林小雨", "text": "...最差？也许不是最差的...上次代码审核我分数还挺高的。但批评的声音就是比赞扬的响..."})
			d.append({"label": "lin_s1_resp2_minimize", "speaker": "林小雨", "text": "（沉默了一会）...你不懂，那不只是一次批评。它让我觉得我这个人就是不够好..."})
			d.append({"speaker": "林小雨", "text": _bond_text(
				"...谢谢你愿意听我说这些。好久没有人认真听我说话了...",
				"和你说话感觉很安心。你真的在认真听我说话。",
				"你真的很懂我。和你说话的时候，我觉得那些消极想法好像没那么可怕了。"
			)})
			d.append({"speaker": "林小雨", "text": _bond_text(
				"也许...也许下次我还可以来？",
				"下周我还想来。我觉得这里能帮到我。",
				"我已经开始期待下一次了。谢谢你。"
			)})
		2:
			d.append({"speaker": "林小雨", "text": "%s我又来了...这周过得很糟糕。" % prefix})
			d.append({"speaker": "林小雨", "text": "我每天醒来就觉得心里很沉。做任何事都提不起劲，觉得自己是个废物..."})
			d.append({
				"choices": [
					{"text": "你说'每天醒来都觉得心里很沉'——这种感觉是从什么时候开始的？", "score_category": "active_listening", "score_points": 3, "feedback": "引用患者原话，深入了解时间线", "id": "lin_s2_explore", "next": "lin_s2_resp1_explore"},
					{"text": "我注意到你用了'废物'这个词。你觉得这个评价客观吗？", "score_category": "cognitive_restructuring", "score_points": 4, "feedback": "识别贴标签的认知扭曲并引导反思", "id": "lin_s2_label", "next": "lin_s2_resp1_label"},
					{"text": "别这么说自己，你不是废物。", "score_category": "rapport", "score_points": -1, "feedback": "直接否定，未能引导自我探索", "id": "lin_s2_reject", "next": "lin_s2_resp1_reject"},
				]
			})
			d.append({"label": "lin_s2_resp1_explore", "speaker": "林小雨", "text": "大概是项目失败之后开始的吧...差不多三周了。每天晚上都睡不好，脑子里全是'我不行'..."})
			d.append({"label": "lin_s2_resp1_label", "speaker": "林小雨", "text": "...废物...你说得对，这个词太极端了。但我该怎么形容这种感觉呢？就是觉得自己什么都做不好..."})
			d.append({"label": "lin_s2_resp1_reject", "speaker": "林小雨", "text": "（叹了口气）...你是不是觉得我在无理取闹？那种感觉是真的...不是我自己想这么想的..."})
			d.append({"speaker": "林小雨", "text": _bond_text(
				"其实...你说得对，'废物'这个词确实太极端了。但我不这么想的话，又该怎么想呢？",
				"你说得对，'废物'这个词太极端了。上次你帮我看到了这一点，这次我想再深入聊聊。",
				"被你这么一提醒，我又意识到了自己的认知扭曲。看来我确实在进步，能更快地发现它了。"
			)})
			d.append({
				"choices": [
					{"text": "我们可以一起试试。你能想一个更平衡的方式来描述现在的状况吗？", "score_category": "cognitive_restructuring", "score_points": 4, "feedback": "引导认知重构，合作式探索", "id": "lin_s2_restructure", "next": "lin_s2_resp2_restructure"},
					{"text": "当你想到'我不行'的时候，有没有什么证据证明你其实是可以的？", "score_category": "socratic_questioning", "score_points": 3, "feedback": "引导寻找反面证据", "id": "lin_s2_evidence", "next": "lin_s2_resp2_evidence"},
					{"text": "你觉得什么都不想做的时候，有没有试过先做一件小事？比如散步10分钟？", "score_category": "rapport", "score_points": 2, "feedback": "行为激活建议，但应先处理认知再建议行动", "id": "lin_s2_activate", "next": "lin_s2_resp2_activate"},
					{"text": "你应该多想想积极的事情。", "score_category": "rapport", "score_points": -2, "feedback": "简单化的建议，缺乏专业引导", "id": "lin_s2_simple", "next": "lin_s2_resp2_simple"},
				]
			})
			d.append({"label": "lin_s2_resp2_restructure", "speaker": "林小雨", "text": "更平衡的方式...也许...'我遇到了一个困难，但我之前也解决过很多问题'？"})
			d.append({"label": "lin_s2_resp2_evidence", "speaker": "林小雨", "text": "证据...上次项目我也解决过好几个技术难题。还有同事夸过我代码写得清楚..."})
			d.append({"label": "lin_s2_resp2_activate", "speaker": "林小雨", "text": "散步...？我以前喜欢散步的，但最近完全没动力出门。也许...我可以试试？"})
			d.append({"label": "lin_s2_resp2_simple", "speaker": "林小雨", "text": "（无力地）我也想积极...但就是做不到啊。那些消极想法像乌云一样笼罩着我..."})
			d.append({"speaker": "林小雨", "text": _bond_text(
				"（她露出了一个微弱的笑容）这样说的时候，感觉确实没那么沉重了。",
				"（微笑）这样说的时候，那些消极想法好像缩小了。",
				"（发自内心地笑了）太好了，我居然能自己找到替代想法了！这都是你教我的方法。"
			)})
			d.append({"speaker": "林小雨", "text": "谢谢你...我会试着这样想的。下周见。"})
		3:
			d.append({"speaker": "林小雨", "text": "%s这周好一点了！我按照你说的，试着注意自己的想法。" % prefix})
			d.append({"speaker": "林小雨", "text": _bond_text(
				"但我还是有时候会突然陷入那种'一切都没用'的感觉里...比如昨天，同事没回我消息，我就立刻觉得是不是讨厌我了。",
				"我能更早地意识到自己的消极思维了。不过昨天同事没回我消息，我还是差点又陷入'她讨厌我'的想法。",
				"我现在能更快地捕捉到自己的认知扭曲了！昨天同事没回消息，我立刻觉察到了'读心术'的苗头。"
			)})
			d.append({
				"choices": [
					{"text": "同事没回消息这件事，除了'讨厌你'之外，还有哪些可能的解释？", "score_category": "socratic_questioning", "score_points": 4, "feedback": "经典的替代解释技术，对抗读心术", "id": "lin_s3_alternative", "next": "lin_s3_resp1_alt"},
					{"text": "你能回想起当时的具体想法吗？脑子里闪过了什么？", "score_category": "active_listening", "score_points": 3, "feedback": "帮助患者捕捉自动化思维", "id": "lin_s3_auto", "next": "lin_s3_resp1_auto"},
					{"text": "别人不回消息是很正常的事，不要想太多。", "score_category": "empathy", "score_points": -2, "feedback": "轻视患者的感受，未深入探索", "id": "lin_s3_dismiss", "next": "lin_s3_resp1_dismiss"},
				]
			})
			d.append({"label": "lin_s3_resp1_alt", "speaker": "林小雨", "text": "其他解释...也许是太忙了？或者没看到？嗯...确实有可能。"})
			d.append({"label": "lin_s3_resp1_auto", "speaker": "林小雨", "text": "当时脑子里闪过的是...'她肯定觉得我很烦，不想理我了'。然后心就开始往下沉..."})
			d.append({"label": "lin_s3_resp1_dismiss", "speaker": "林小雨", "text": "（有些委屈）...我知道是正常的，但我控制不住那种感觉啊。一发生就自动往最坏的方向想..."})
			d.append({"speaker": "林小雨", "text": _bond_text(
				"我发现我总是自动往最坏的方向想。这种模式...好像从小就有。",
				"我发现我总是自动往最坏的方向想。但现在我能意识到了，这就是进步，对吧？",
				"我发现这些消极思维模式已经很久了，但我现在有方法来应对它们了。感觉自己越来越有力量。"
			)})
			d.append({"speaker": "林小雨", "text": "（深呼吸）但我现在能意识到这个模式了。谢谢你的帮助，真的。"})
			d.append({"speaker": "林小雨", "text": "我想继续治疗。我觉得我在变好。"})
		_:
			d.append({"speaker": "林小雨", "text": "%s今天感觉还不错。谢谢你一直以来的帮助。" % prefix})
			if BattleEngine and BattleEngine.get_patient_data("lin_xiaoyu").size() > 0:
				var be_dep: int = BattleEngine.get_stat("lin_xiaoyu", "depression")
				var be_hope: int = BattleEngine.get_stat("lin_xiaoyu", "hope")
				if be_dep <= 20 and be_hope >= 60:
					d.append({"speaker": "林小雨", "text": "（发自内心地笑了）我现在真的觉得一切都会好起来的。谢谢你帮了我这么多。"})
					d.append({"speaker": "林小雨", "text": "我已经掌握了应对消极想法的方法。这些工具会一直陪着我。"})
				elif be_dep <= 40:
					d.append({"speaker": "林小雨", "text": _bond_text(
						"我学会了一些方法来应对负面想法。虽然偶尔还是会低落，但我知道怎么处理了。",
						"那些方法真的很有效。现在消极想法来的时候，我能更快地调整过来。",
						"我觉得我已经掌握了应对的方法。你教会了我很多，我会一直用下去的。"
					)})
				else:
					d.append({"speaker": "林小雨", "text": _bond_text(
						"嗯...有时候方法有用，有时候消极想法还是会涌上来。",
						"我在学着用你教的方法。虽然进步慢，但至少在往前走。",
						"谢谢你没有放弃我。我会继续努力的。"
					)})
			else:
				d.append({"speaker": "林小雨", "text": _bond_text(
					"我学会了一些方法来应对负面想法。虽然偶尔还是会低落，但我知道怎么处理了。",
					"那些方法真的很有效。现在消极想法来的时候，我能更快地调整过来。",
					"我觉得我已经掌握了应对的方法。你教会了我很多，我会一直用下去的。"
				)})
			d.append({"speaker": "林小雨", "text": "（微笑）我想，我会好起来的。"})
	return d

func _zhang_dialogue(s: int) -> Array[Dictionary]:
	var d: Array[Dictionary] = []
	var prefix := _emotion_prefix()
	match s:
		1:
			d.append({"speaker": "张浩", "text": "（紧张地搓着手）%s你好...我是张浩。我...我最近总是特别焦虑。" % prefix})
			d.append({"speaker": "张浩", "text": _bond_text(
				"每天脑子里都在想最坏的结果。工作、健康、家人...什么都要担心。停不下来。",
				"每天都活在担忧里。工作、健康、家人...什么都担心。但其实...上次和你聊过之后好了一些。",
				"这周我试着用你教我的方法了。虽然还是很焦虑，但至少知道怎么应对了。"
			)})
			d.append({
				"choices": [
					{"text": "你脑中担心的事情，有多少是真正发生了的？", "score_category": "socratic_questioning", "score_points": 4, "feedback": "引导检视灾难化思维的现实基础", "id": "zhang_s1_reality", "next": "zhang_s1_resp1_reality"},
					{"text": "听起来你承受了很多。能具体说说最让你担心的是什么吗？", "score_category": "empathy", "score_points": 3, "feedback": "共情并引导聚焦具体问题", "id": "zhang_s1_focus", "next": "zhang_s1_resp1_focus"},
					{"text": "想太多没用的，放松点。", "score_category": "rapport", "score_points": -3, "feedback": "轻视焦虑症状，缺乏理解", "id": "zhang_s1_relax", "next": "zhang_s1_resp1_relax"},
				]
			})
			d.append({"label": "zhang_s1_resp1_reality", "speaker": "张浩", "text": "真正发生的...嗯，好像大部分我担心的事都没有发生。但我控制不住啊！"})
			d.append({"label": "zhang_s1_resp1_focus", "speaker": "张浩", "text": "最担心的...大概是健康吧。比如上周我肚子疼了一下，我就立刻觉得是不是得了什么大病..."})
			d.append({"label": "zhang_s1_resp1_relax", "speaker": "张浩", "text": "（有些抵触）...如果能放松我还用来看你吗？你根本不了解这种感觉..."})
			d.append({"speaker": "张浩", "text": "比如上周我肚子疼了一下，我就立刻觉得是不是得了什么大病...去医院检查了，什么事都没有。"})
			d.append({
				"choices": [
					{"text": "这是一个很好的例子。你能描述一下当时从'肚子疼'到'得大病'之间，脑子里经历了什么吗？", "score_category": "active_listening", "score_points": 3, "feedback": "帮助患者识别自动化思维链条", "id": "zhang_s1_chain", "next": "zhang_s1_resp2_chain"},
					{"text": "[需要认知重构Lv.2] 让我们把你的思维画成一条链：肚子疼→得了大病→我会死。这条链的每一步都成立吗？", "score_category": "cognitive_restructuring", "score_points": 5, "feedback": "高级认知链分析，系统性解构灾难化思维", "id": "zhang_s1_chain_advanced", "requires_skill": "cognitive", "requires_level": 2, "next": "zhang_s1_resp2_adv"},
					{"text": "检查结果没事，这对你来说意味着什么？", "score_category": "cognitive_restructuring", "score_points": 3, "feedback": "引导患者从经验中学习", "id": "zhang_s1_learn", "next": "zhang_s1_resp2_learn"},
				]
			})
			d.append({"label": "zhang_s1_resp2_chain", "speaker": "张浩", "text": "当时脑子里就是...肚子疼→是不是癌症→我要死了→家里人怎么办...然后就喘不上气了。"})
			d.append({"label": "zhang_s1_resp2_adv", "speaker": "张浩", "text": "（思考了一下）每一步...肚子疼到癌症？这个跳跃确实太大了。大部分肚子疼就是普通的消化问题..."})
			d.append({"label": "zhang_s1_resp2_learn", "speaker": "张浩", "text": "意味着...我之前的担心是多余的？确实，每次担心的事最后都没发生。但我下次还是会控制不住..."})
			d.append({"speaker": "张浩", "text": _bond_text(
				"（松了口气）和你聊聊之后...好像没那么紧张了。下周还能来吗？",
				"（明显放松了）每次和你聊完都觉得轻松不少。下周见。",
				"（微笑着）你总是能帮我找到理性的角度。谢谢你，下周见！"
			)})
		2:
			d.append({"speaker": "张浩", "text": "%s又来了...不过这次我试着你说的方法，焦虑的时候先停下来评估一下概率。" % prefix})
			d.append({"speaker": "张浩", "text": _bond_text(
				"有点用。虽然还是焦虑，但至少不会立刻陷入恐慌了。",
				"有效果！我发现自己能在焦虑升级之前踩个刹车了。",
				"效果很明显！我现在能快速识别灾难化思维并叫停它。"
			)})
			d.append({
				"choices": [
					{"text": "能举个具体的例子吗？你是怎么停下来评估的？", "score_category": "active_listening", "score_points": 3, "feedback": "引导患者反思具体策略应用", "id": "zhang_s2_example", "next": "zhang_s2_resp1_example"},
					{"text": "当你评估完概率后，焦虑程度有变化吗？", "score_category": "cognitive_restructuring", "score_points": 4, "feedback": "强化认知重构的效果体验", "id": "zhang_s2_assess", "next": "zhang_s2_resp1_assess"},
					{"text": "除了评估概率，你还可以试试4-7-8呼吸法：吸气4秒→屏息7秒→呼气8秒。", "score_category": "rapport", "score_points": 2, "feedback": "放松技术建议，可辅助但非核心CBT", "id": "zhang_s2_breath", "next": "zhang_s2_resp1_breath"},
					{"text": "焦虑是正常的，不用太在意。", "score_category": "empathy", "score_points": -2, "feedback": "弱化患者感受，未深入引导", "id": "zhang_s2_dismiss", "next": "zhang_s2_resp1_dismiss"},
				]
			})
			d.append({"label": "zhang_s2_resp1_example", "speaker": "张浩", "text": "昨天老板发了一条消息说'谈谈'，我立刻觉得要被开了。但评估之后，概率其实很低。结果只是聊个项目。"})
			d.append({"label": "zhang_s2_resp1_assess", "speaker": "张浩", "text": "变化很大！比如老板说'谈谈'，我评估了被开除的概率大概只有5%。想完之后心跳就慢下来了。"})
			d.append({"label": "zhang_s2_resp1_breath", "speaker": "张浩", "text": "4-7-8呼吸法？听起来很简单。我下次焦虑的时候试试看，也许能帮我冷静下来。"})
			d.append({"label": "zhang_s2_resp1_dismiss", "speaker": "张浩", "text": "（有些失落）...你说的对，焦虑是正常的。但那种恐惧感一点都不正常...感觉你不太理解我..."})
			d.append({"speaker": "张浩", "text": "我觉得我在学着和焦虑共处了。谢谢你的方法。"})
		_:
			d.append({"speaker": "张浩", "text": "%s最近焦虑明显减少了。" % prefix})
			if BattleEngine and BattleEngine.get_patient_data("zhang_hao").size() > 0:
				var be_ins: int = BattleEngine.get_stat("zhang_hao", "insight")
				if be_ins >= 40:
					d.append({"speaker": "张浩", "text": "我现在能很快识别灾难化思维并叫停它了。你教的方法真的改变了我的生活。"})
				elif be_ins >= 20:
					d.append({"speaker": "张浩", "text": _bond_text(
						"焦虑还是会出现，但我知道怎么应对了。谢谢你的方法。",
						"我能更快地管理焦虑了。这些方法真的很实用。",
						"焦虑已经不再是控制我的主人了。谢谢你帮我找回了自己。"
					)})
				else:
					d.append({"speaker": "张浩", "text": _bond_text(
						"嗯...有时候方法有用，有时候还是会控制不住。",
						"我在学着用你教的方法。偶尔还是焦虑，但不会完全失控了。",
						"谢谢你的耐心。我在慢慢进步。"
					)})
			else:
				d.append({"speaker": "张浩", "text": _bond_text(
					"你教的方法我会继续用的。虽然偶尔还是会焦虑，但不会失控了。",
					"我觉得我越来越能管理焦虑了。这些方法真的很实用。",
					"焦虑已经不再是控制我的主人了。谢谢你帮我找回了自己。"
				)})
	return d

func _wang_dialogue(s: int) -> Array[Dictionary]:
	var d: Array[Dictionary] = []
	var prefix := _emotion_prefix()
	match s:
		1:
			d.append({"speaker": "王美", "text": "%s你好...我是王美。他们说让我来这里聊聊..." % prefix})
			d.append({"speaker": "王美", "text": _bond_text(
				"其实也没什么好聊的。就是觉得什么事情都是我的错...工作做不好，朋友也处不好...",
				"我总是觉得什么事情都怪自己。同事不高兴，我就觉得是我的问题。",
				"我想学着不再什么错都往自己身上揽了。"
			)})
			d.append({
				"choices": [
					{"text": "你说'都是你的错'——能举个例子吗？具体发生了什么？", "score_category": "active_listening", "score_points": 3, "feedback": "引导具体化，避免泛化归因", "id": "wang_s1_example", "next": "wang_s1_resp1_example"},
					{"text": "我听到你在很多事情上都把责任归给自己。你觉得这公平吗？", "score_category": "socratic_questioning", "score_points": 4, "feedback": "挑战个人化认知扭曲", "id": "wang_s1_personal", "next": "wang_s1_resp1_personal"},
					{"text": "不要什么都怪自己，这样不好。", "score_category": "rapport", "score_points": -2, "feedback": "简单安慰，未引导反思", "id": "wang_s1_dismiss", "next": "wang_s1_resp1_dismiss"},
				]
			})
			d.append({"label": "wang_s1_resp1_example", "speaker": "王美", "text": "比如上周项目延期了，虽然整个团队都有责任，但我就觉得主要是我的错..."})
			d.append({"label": "wang_s1_resp1_personal", "speaker": "王美", "text": "...公平？也许不公平吧。但我就是控制不住，一出事就先怪自己。比如上周项目延期了，虽然整个团队都有责任，但我就觉得主要是我的错..."})
			d.append({"label": "wang_s1_resp1_dismiss", "speaker": "王美", "text": "（有些无奈）我知道这样不好...但我改不了啊。一有事情出错我就条件反射地怪自己。比如上周项目延期了，虽然整个团队都有责任，但我就觉得主要是我的错..."})
			d.append({"speaker": "王美", "text": _bond_text(
				"（犹豫地）你觉得...这不全是我的错？",
				"（思考着）也许确实不全是我的责任...但要怎么分清呢？",
				"你说得对，我总是第一时间怪自己。我想学着更客观地看待事情。"
			)})
			d.append({
				"choices": [
					{"text": "我们可以一起分析一下。项目延期，除了你之外还有哪些因素？", "score_category": "cognitive_restructuring", "score_points": 4, "feedback": "引导多因归因，打破个人化", "id": "wang_s1_factors", "next": "wang_s1_resp2_factors"},
					{"text": "如果同事遇到同样的情况，你会觉得全是她的错吗？", "score_category": "socratic_questioning", "score_points": 3, "feedback": "双标准技术，促进自我同情", "id": "wang_s1_double", "next": "wang_s1_resp2_double"},
					{"text": "[需要认知重构Lv.3] 让我们做个实验：列出项目中每个人的责任比例，看看你的'100%是我的错'是否成立。", "score_category": "cognitive_restructuring", "score_points": 6, "feedback": "高级行为实验技术，用数据挑战个人化", "id": "wang_s1_experiment", "requires_skill": "cognitive", "requires_level": 3, "next": "wang_s1_resp2_experiment"},
				]
			})
			d.append({"label": "wang_s1_resp2_factors", "speaker": "王美", "text": "（开始数手指）需求变更、测试环境出问题、人手不足...嗯，好像确实不全是我的问题。"})
			d.append({"label": "wang_s1_resp2_double", "speaker": "王美", "text": "（惊讶）你说得对...如果同事这样，我不会怪她的。那我为什么要怪自己呢？"})
			d.append({"label": "wang_s1_resp2_experiment", "speaker": "王美", "text": "（认真地列了一会）我大概占20%？需求方占了40%，还有时间不够...天哪，我之前真的以为全是我的错！"})
			d.append({"speaker": "王美", "text": _bond_text(
				"（惊讶）你说得对...如果同事这样，我不会怪她的。那我为什么要怪自己呢？",
				"（恍然大悟）我确实对自己太苛刻了。谢谢你的提醒。",
				"（微笑）我又学到了一个新方法。下次再出现这种想法的时候，我会用双标准来检查。"
			)})
		2:
			d.append({"speaker": "王美", "text": "%s我又来了。这周我试着你说的方法，遇到事情先不急着怪自己。" % prefix})
			d.append({"speaker": "王美", "text": _bond_text(
				"不过...昨天同事在群里发了条消息，我回复了之后没人理我。我立刻就想'是不是我说错话了，大家都讨厌我了'。",
				"我昨天遇到了一件事——同事在群里发了消息，我回复后没人理我。我第一反应又是'我是不是说错话了'。",
				"昨天我遇到了类似的情况——群里没人回我。但我这次停下来了，没有立刻怪自己。"
			)})
			d.append({
				"choices": [
					{"text": "你停下来了这个过程——这本身就是一个很大的进步。然后呢？", "score_category": "active_listening", "score_points": 3, "feedback": "肯定进步并引导继续探索", "id": "wang_s2_acknowledge", "next": "wang_s2_resp1_ack"},
					{"text": "我们来检验一下：'没人理我'可能有哪些原因？", "score_category": "socratic_questioning", "score_points": 4, "feedback": "引导多因分析，对抗个人化", "id": "wang_s2_check", "next": "wang_s2_resp1_check"},
					{"text": "别太在意群消息，这不重要。", "score_category": "rapport", "score_points": -2, "feedback": "轻视患者感受，未引导反思", "id": "wang_s2_dismiss", "next": "wang_s2_resp1_dismiss"},
				]
			})
			d.append({"label": "wang_s2_resp1_ack", "speaker": "王美", "text": "（有些自豪）嗯！然后我问自己：'如果是小丽发了同样的消息没人回，我会觉得她讨厌人吗？'答案是不会。"})
			d.append({"label": "wang_s2_resp1_check", "speaker": "王美", "text": "原因...可能是大家都在忙？或者消息被刷上去了？嗯，仔细想想，群消息确实经常被忽略的。"})
			d.append({"label": "wang_s2_resp1_dismiss", "speaker": "王美", "text": "（有些委屈）对你来说不重要，但对我来说，那种被忽视的感觉很真实..."})
			d.append({"speaker": "王美", "text": _bond_text(
				"你说得对，我好像开始能跳出'都是我的错'的模式了。",
				"双标准技术真的好用。我现在能更快地发现自己在个人化了。",
				"我发现很多时候真的不是我的问题。这种认识让我轻松了很多。"
			)})
			d.append({
				"choices": [
					{"text": "你已经在用双标准技术了！想不想试试把它变成一个日常习惯？", "score_category": "cognitive_restructuring", "score_points": 4, "feedback": "巩固认知行为改变，引导习惯化", "id": "wang_s2_habit", "next": "wang_s2_resp2_habit"},
					{"text": "你觉得这种'什么都怪自己'的模式，是从什么时候开始的？", "score_category": "socratic_questioning", "score_points": 3, "feedback": "深入探索归因模式的历史根源", "id": "wang_s2_origin", "next": "wang_s2_resp2_origin"},
					{"text": "你做得很好，继续保持就好。", "score_category": "rapport", "score_points": 0, "feedback": "简单鼓励，缺乏深入引导", "id": "wang_s2_simple", "next": "wang_s2_resp2_simple"},
				]
			})
			d.append({"label": "wang_s2_resp2_habit", "speaker": "王美", "text": "日常习惯？嗯...也许我可以在手机上设个提醒，每天晚上问问自己'今天有没有不公平地责备自己？'"})
			d.append({"label": "wang_s2_resp2_origin", "speaker": "王美", "text": "从什么时候...我想想。大概小时候吧，我妈总说'都是你害的'。也许从那时起我就学会了什么事都往自己身上揽..."})
			d.append({"label": "wang_s2_resp2_simple", "speaker": "王美", "text": "谢谢...不过有时候我还是会自动怪自己。可能需要更多练习。"})
			d.append({"speaker": "王美", "text": _bond_text(
				"（点头）我会继续练习的。下次见。",
				"（微笑）我觉得我在进步。谢谢你陪我一起找方法。",
				"（自信地）我已经有了应对的方法。下次遇到类似情况，我知道该怎么做了。"
			)})
		3:
			d.append({"speaker": "王美", "text": "%s我来告诉你一个好消息！" % prefix})
			d.append({"speaker": "王美", "text": _bond_text(
				"昨天项目又出问题了。以前我肯定立刻怪自己，但这次...我居然停下来了！",
				"这周我用你教的方法，在遇到问题时先分析原因，而不是急着自责。效果很明显！",
				"我现在已经有了一个习惯：遇到问题先问'这真的全是我的错吗？'大部分时候答案都是不是。"
			)})
			d.append({
				"choices": [
					{"text": "你能描述一下这次是怎么应对的吗？", "score_category": "active_listening", "score_points": 3, "feedback": "引导患者回顾成功策略，强化正面体验", "id": "wang_s3_detail", "next": "wang_s3_resp1_detail"},
					{"text": "你从'什么都怪自己'到现在能停下来分析——这个转变是怎么发生的？", "score_category": "socratic_questioning", "score_points": 4, "feedback": "促进元认知，让患者理解自己的改变过程", "id": "wang_s3_meta", "next": "wang_s3_resp1_meta"},
					{"text": "做得不错，继续加油。", "score_category": "rapport", "score_points": 0, "feedback": "简单鼓励，未深入探索", "id": "wang_s3_simple", "next": "wang_s3_resp1_simple"},
				]
			})
			d.append({"label": "wang_s3_resp1_detail", "speaker": "王美", "text": "项目需求又变了，我第一反应还是'是我的错'。但我立刻用双标准问自己——'如果是同事遇到，我会怪她吗？'不会。然后我就冷静下来了。"})
			d.append({"label": "wang_s3_resp1_meta", "speaker": "王美", "text": "转变...大概是每次你都没有否定我的感受，而是帮我看到其他可能性。慢慢地，我学会了自己做这件事。"})
			d.append({"label": "wang_s3_resp1_simple", "speaker": "王美", "text": "谢谢！虽然偶尔还是会习惯性地想怪自己，但至少能叫停了。"})
			d.append({"speaker": "王美", "text": _bond_text(
				"谢谢你一直以来的耐心。我觉得我不再是什么错都往自己身上揽的人了。",
				"你的方法真的改变了我。我现在能更公平地看待事情了。",
				"我觉得我已经掌握了这些工具。以后遇到类似情况，我知道该怎么保护自己了。"
			)})
			d.append({"speaker": "王美", "text": "（微笑）我想，我会好起来的。谢谢你。"})
		_:
			d.append({"speaker": "王美", "text": "%s最近我在练习你说的方法。" % prefix})
			if BattleEngine and BattleEngine.get_patient_data("wang_mei").size() > 0:
				var be_avoid: int = BattleEngine.get_stat("wang_mei", "avoidance")
				if be_avoid <= 15:
					d.append({"speaker": "王美", "text": "我已经很少无条件地责怪自己了。这个改变让我轻松了很多。谢谢你。"})
				elif be_avoid <= 30:
					d.append({"speaker": "王美", "text": _bond_text(
						"有时候还是会习惯性地怪自己，但至少能意识到了。",
						"我能更快地捕捉到'个人化'的思维了。",
						"我已经很少无条件地责怪自己了。这个改变让我轻松了很多。"
					)})
				else:
					d.append({"speaker": "王美", "text": _bond_text(
						"我...可能还需要更多时间来改变。",
						"有时候能意识到自己在怪自己了，但习惯很难改。",
						"谢谢你的耐心。我在努力改变。"
					)})
			else:
				d.append({"speaker": "王美", "text": _bond_text(
					"有时候还是会习惯性地怪自己，但至少能意识到了。",
					"我能更快地捕捉到'个人化'的思维了。",
					"我已经很少无条件地责怪自己了。这个改变让我轻松了很多。"
				)})
	return d

func _show_retry_dialogue():
	var d: Array[Dictionary] = []
	var chapter_id := _get_chapter_id()
	var chapter_def: Dictionary = GameManager.get_chapter_def(chapter_id)
	var min_grade: String = chapter_def.get("min_grade", "D")
	var scores: Array = GameManager.patient_scores.get(patient_id, [])
	var grades_text := ""
	for s_data in scores:
		grades_text += "%s " % s_data.get("grade", "D")
	
	var pname: String = GameManager.PATIENT_NAMES.get(patient_id, npc_name)
	
	d.append({"speaker": "系统", "text": "【章节未通过】%s的治疗评级未达到要求。" % pname})
	d.append({"speaker": "系统", "text": "章节要求: 最低%s级\n你的治疗评级: %s" % [min_grade, grades_text]})
	d.append({"speaker": "系统", "text": "你可以重新与%s对话，追加治疗次数。争取更好的评分来通过章节！" % pname})
	d.append({"speaker": "系统", "text": "[提示] 选择共情、倾听类回应在患者防御时效果更好；认知重构类在患者反思时效果更好。按K键查看技能树。"})
	max_sessions += 1
	DialogueManager.start_dialogue(d)

func _show_completion_dialogue():
	var d: Array[Dictionary] = []
	var bond := GameManager.get_bond(patient_id)
	var scores: Array = GameManager.patient_scores.get(patient_id, [])
	var total := 0
	for s in scores:
		total += s.get("total", 0)
	var avg := total / maxi(scores.size(), 1)
	var grade := ScoringSystem.get_grade(avg)
	var be_state: String = ""
	if BattleEngine and BattleEngine.get_patient_data(patient_id).size() > 0:
		be_state = BattleEngine.get_state_name(patient_id)
	
	match patient_id:
		"lin_xiaoyu":
			if grade == "S" or grade == "A":
				d.append({"speaker": "林小雨", "text": "（微笑着）谢谢你。你真的帮我重新看到了自己。"})
				d.append({"speaker": "林小雨", "text": "我现在知道，就算项目出了问题，也不代表我是个废物。我有自己的价值。"})
				d.append({"speaker": "林小雨", "text": "（深吸一口气）我觉得我已经准备好面对未来了。谢谢你。"})
			elif grade == "B" or grade == "C":
				d.append({"speaker": "林小雨", "text": "谢谢你这段时间的陪伴。虽然偶尔还是会有消极想法，但我知道怎么应对了。"})
				d.append({"speaker": "林小雨", "text": "（微微一笑）我会继续练习你教我的方法的。"})
			else:
				d.append({"speaker": "林小雨", "text": "...谢谢你来陪我聊。虽然我觉得...可能还是没什么用。"})
				d.append({"speaker": "林小雨", "text": "（低着头）也许以后会好起来吧..."})
		"zhang_hao":
			if grade == "S" or grade == "A":
				d.append({"speaker": "张浩", "text": "（放松地笑）你知道吗，我现在肚子疼的时候，第一反应不再是'我要死了'了。"})
				d.append({"speaker": "张浩", "text": "我会先停下来评估一下概率。这个改变太大了。"})
				d.append({"speaker": "张浩", "text": "谢谢你教会我如何和焦虑共处。我真的变了很多。"})
			elif grade == "B" or grade == "C":
				d.append({"speaker": "张浩", "text": "（点头）你的方法确实有效。虽然还是偶尔会焦虑，但不会恐慌了。"})
				d.append({"speaker": "张浩", "text": "我会继续练习评估概率的技巧。谢谢。"})
			else:
				d.append({"speaker": "张浩", "text": "（紧张地搓手）嗯...可能需要更多时间吧。"})
				d.append({"speaker": "张浩", "text": "我还是会控制不住地往坏处想...但至少知道有方法可以试试。"})
		"wang_mei":
			if grade == "S" or grade == "A":
				d.append({"speaker": "王美", "text": "（微笑着）你让我学会了不再什么错都往自己身上揽。"})
				d.append({"speaker": "王美", "text": "上次项目出问题，我居然能冷静地分析每个人的责任，而不是先怪自己！"})
				d.append({"speaker": "王美", "text": "我觉得我变得更自信了。谢谢你。"})
			elif grade == "B" or grade == "C":
				d.append({"speaker": "王美", "text": "谢谢你的帮助。我现在能意识到自己又在'个人化'了。"})
				d.append({"speaker": "王美", "text": "虽然偶尔还会习惯性怪自己，但至少能叫停了。"})
			else:
				d.append({"speaker": "王美", "text": "...嗯，谢谢你愿意听我说。"})
				d.append({"speaker": "王美", "text": "可能我还是太习惯怪自己了...但知道有人愿意帮我，感觉好一些。"})
		_:
			d.append({"speaker": npc_name, "text": "谢谢你这段时间的帮助。"})
			d.append({"speaker": npc_name, "text": "（微笑）希望你也能帮助更多的人。"})
	
	d.append({"speaker": "你", "text": _get_relapse_prevention()})
	CbtTutorial._on_trigger("relapse_prevention")
	DialogueManager.start_dialogue(d)

func _get_relapse_prevention() -> String:
	match patient_id:
		"lin_xiaoyu": return "在结束之前，我想和你一起回顾一下。如果以后消极想法又出现了，记住：1.觉察到它——这是认知扭曲在作祟。2.问自己——有什么证据支持这个想法？3.用更平衡的方式重新描述。你已经有这些工具了。"
		"zhang_hao": return "最后，让我们一起做个复发预防计划。如果以后焦虑又加剧了：1.先停下来做4-7-8呼吸。2.评估你担心的结果实际发生的概率。3.制定具体的应对计划。记住，你已经有这些策略了。"
		"wang_mei": return "治疗结束前，我想提醒你：如果以后又开始怪自己了，记住这三步：1.停下来问——如果是朋友遇到，我会怪她吗？2.列出所有可能的原因，不只看自己。3.对自己友善一点。你已经不再是以前那个什么都揽到自己身上的你了。"
		_: return "记住你在治疗中学到的方法，它们是你一生的工具。"

func _update_expression():
	var hope_val: float = emotion.get("hope", 0)
	var dep_val: float = emotion.get("depression", 50)
	var anx_val: float = emotion.get("anxiety", 0)
	if BattleEngine and BattleEngine.get_patient_data(patient_id).size() > 0:
		hope_val = BattleEngine.get_stat(patient_id, "hope")
		dep_val = BattleEngine.get_stat(patient_id, "depression")
		anx_val = BattleEngine.get_stat(patient_id, "anxiety")
	if hope_val > 60:
		current_expression = "happy"
	elif dep_val > 60:
		current_expression = "sad"
	elif anx_val > 60:
		current_expression = "anxious"
	else:
		current_expression = "normal"
	sprite.play("idle_" + facing)
