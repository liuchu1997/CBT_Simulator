extends Node

signal tutorial_shown(tutorial_id: String, title: String, text: String)

var _tutorials := {
	"first_distortion": {
		"title": "【认知扭曲】",
		"text": "你刚遇到了一个认知扭曲！\n认知扭曲是思维中的习惯性偏差，比如'非黑即白'地看问题。\n在接下来的对话中，试着选择帮助患者发现这些偏差的回应。",
	},
	"first_good_choice": {
		"title": "【做得好！】",
		"text": "你的回应帮助患者感到被理解了。\n这就是共情倾听——先理解感受，再引导思考。",
	},
	"first_bad_choice": {
		"title": "【提示】",
		"text": "这次回应没有达到理想效果。\n在给建议之前，先让患者充分表达。\n尝试用开放式问题代替直接建议。",
	},
	"first_score": {
		"title": "【评分报告】",
		"text": "治疗结束！五个维度分别代表不同的治疗技能。\n分数越高说明你的回应越专业。\n按 K 键可以查看和升级你的技能树。",
	},
	"trust_up": {
		"title": "【信任提升】",
		"text": "患者的信任度提升了！\n信任是治疗关系的核心。\n当患者更信任你时，他们会分享更多内心的想法。",
	},
	"bond_decay": {
		"title": "【注意】",
		"text": "有一段时间没和某位患者互动了，\n他们的信任度略有下降。\n定期治疗可以维持治疗关系。",
	},
	"first_resilient_hint": {
		"title": "【突破！】",
		"text": "你帮助患者达到了'恢复中'的状态！\n这说明你的治疗正在起效。\n继续保持专业的治疗态度。",
	},
	"cognitive_triangle": {
		"title": "【CBT核心：认知三角】",
		"text": "CBT的核心原理是认知三角：\n思维 → 情绪 → 行为\n三者互相影响。改变消极思维，就能改善情绪和行为。\n例如：'我是废物'(思维) → 抑郁(情绪) → 什么都不做(行为)",
	},
	"homework_assigned": {
		"title": "【家庭作业】",
		"text": "每次治疗结束后，你给患者布置了练习。\n家庭作业是CBT的关键环节——让患者在日常生活中练习新技能。\n下次治疗开始时，会回顾作业完成情况。",
	},
	"behavioral_activation": {
		"title": "【CBT技术：行为激活】",
		"text": "行为激活是治疗抑郁的重要技术。\n抑郁让人不想动→不动→更抑郁，形成恶性循环。\n打破循环的方法：从一件小事开始行动，哪怕只是散步10分钟。",
	},
	"relaxation_technique": {
		"title": "【CBT技术：放松训练】",
		"text": "放松训练可以帮助缓解焦虑的身体症状。\n4-7-8呼吸法：吸气4秒→屏息7秒→呼气8秒。\n配合认知重构使用效果更佳。",
	},
	"relapse_prevention": {
		"title": "【复发预防】",
		"text": "治疗结束时，帮助患者制定复发预防计划很重要。\n包括：1.识别早期预警信号 2.回顾有效的应对策略 3.知道何时寻求帮助\n这是CBT治疗的重要环节。",
	},
}

var _queue: Array[String] = []
var _is_showing: bool = false

func _ready():
	GameManager.tutorial_trigger.connect(_on_trigger)

func _on_trigger(tutorial_id: String):
	if GameManager.tutorials_shown.has(tutorial_id):
		return
	GameManager.tutorials_shown[tutorial_id] = true
	_queue.append(tutorial_id)
	if not _is_showing:
		_show_next()

func _show_next():
	if _queue.is_empty():
		_is_showing = false
		return
	_is_showing = true
	var tid: String = _queue.pop_front()
	if _tutorials.has(tid):
		var data: Dictionary = _tutorials[tid]
		tutorial_shown.emit(tid, data.get("title", ""), data.get("text", ""))

func dismiss_current():
	GameManager.save_game()
	_show_next()

func force_show(tutorial_id: String):
	if _tutorials.has(tutorial_id):
		var data: Dictionary = _tutorials[tutorial_id]
		tutorial_shown.emit(tutorial_id, data.get("title", ""), data.get("text", ""))
