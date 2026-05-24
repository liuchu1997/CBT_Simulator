extends Node

signal tutorial_shown(tutorial_id: String, title: String, text: String)

var _tutorials := {
	"first_distortion": {
		"title": "【认知扭曲】", "title_en": "[Cognitive Distortion]",
		"text": "你刚遇到了一个认知扭曲！\n认知扭曲是思维中的习惯性偏差，比如'非黑即白'地看问题。\n在接下来的对话中，试着选择帮助患者发现这些偏差的回应。",
		"text_en": "You just encountered a cognitive distortion!\nCognitive distortions are habitual biases in thinking, like 'all-or-nothing' thinking.\nIn the upcoming dialogue, try choosing responses that help the patient discover these biases.",
	},
	"first_good_choice": {
		"title": "【做得好！】", "title_en": "[Well Done!]",
		"text": "你的回应帮助患者感到被理解了。\n这就是共情倾听——先理解感受，再引导思考。",
		"text_en": "Your response helped the patient feel understood.\nThis is empathic listening — understand feelings first, then guide thinking.",
	},
	"first_bad_choice": {
		"title": "【提示】", "title_en": "[Tip]",
		"text": "这次回应没有达到理想效果。\n在给建议之前，先让患者充分表达。\n尝试用开放式问题代替直接建议。",
		"text_en": "This response didn't achieve the ideal effect.\nBefore giving advice, let the patient express themselves fully.\nTry open-ended questions instead of direct suggestions.",
	},
	"first_score": {
		"title": "【评分报告】", "title_en": "[Score Report]",
		"text": "治疗结束！五个维度分别代表不同的治疗技能。\n分数越高说明你的回应越专业。\n按 K 键可以查看和升级你的技能树。",
		"text_en": "Session complete! The five dimensions represent different therapy skills.\nHigher scores mean more professional responses.\nPress K to view and upgrade your skill tree.",
	},
	"trust_up": {
		"title": "【信任提升】", "title_en": "[Trust Increased]",
		"text": "患者的信任度提升了！\n信任是治疗关系的核心。\n当患者更信任你时，他们会分享更多内心的想法。",
		"text_en": "The patient's trust level has increased!\nTrust is the core of the therapeutic relationship.\nWhen patients trust you more, they'll share more of their inner thoughts.",
	},
	"bond_decay": {
		"title": "【注意】", "title_en": "[Notice]",
		"text": "有一段时间没和某位患者互动了，\n他们的信任度略有下降。\n定期治疗可以维持治疗关系。",
		"text_en": "It's been a while since you interacted with a patient.\nTheir trust level has slightly decreased.\nRegular sessions help maintain the therapeutic relationship.",
	},
	"first_resilient_hint": {
		"title": "【突破！】", "title_en": "[Breakthrough!]",
		"text": "你帮助患者达到了'恢复中'的状态！\n这说明你的治疗正在起效。\n继续保持专业的治疗态度。",
		"text_en": "You helped the patient reach a 'Recovering' state!\nThis shows your therapy is working.\nKeep up the professional therapeutic approach.",
	},
	"cognitive_triangle": {
		"title": "【CBT核心：认知三角】", "title_en": "[CBT Core: Cognitive Triangle]",
		"text": "CBT的核心原理是认知三角：\n思维 → 情绪 → 行为\n三者互相影响。改变消极思维，就能改善情绪和行为。\n例如：'我是废物'(思维) → 抑郁(情绪) → 什么都不做(行为)",
		"text_en": "The core principle of CBT is the Cognitive Triangle:\nThoughts → Emotions → Behaviors\nThey influence each other. Change negative thoughts to improve emotions and behaviors.\nExample: 'I'm worthless' (Thought) → Depression (Emotion) → Do nothing (Behavior)",
	},
	"homework_assigned": {
		"title": "【家庭作业】", "title_en": "[Homework]",
		"text": "每次治疗结束后，你给患者布置了练习。\n家庭作业是CBT的关键环节——让患者在日常生活中练习新技能。\n下次治疗开始时，会回顾作业完成情况。",
		"text_en": "After each session, you assign exercises to the patient.\nHomework is a key part of CBT — helping patients practice new skills in daily life.\nAt the start of the next session, homework completion will be reviewed.",
	},
	"behavioral_activation": {
		"title": "【CBT技术：行为激活】", "title_en": "[CBT Technique: Behavioral Activation]",
		"text": "行为激活是治疗抑郁的重要技术。\n抑郁让人不想动→不动→更抑郁，形成恶性循环。\n打破循环的方法：从一件小事开始行动，哪怕只是散步10分钟。",
		"text_en": "Behavioral activation is an important technique for treating depression.\nDepression makes you not want to move → not moving → more depressed, a vicious cycle.\nBreak the cycle: start with one small action, even just a 10-minute walk.",
	},
	"relaxation_technique": {
		"title": "【CBT技术：放松训练】", "title_en": "[CBT Technique: Relaxation]",
		"text": "放松训练可以帮助缓解焦虑的身体症状。\n4-7-8呼吸法：吸气4秒→屏息7秒→呼气8秒。\n配合认知重构使用效果更佳。",
		"text_en": "Relaxation training can help relieve physical symptoms of anxiety.\n4-7-8 Breathing: Inhale 4 seconds → Hold 7 seconds → Exhale 8 seconds.\nWorks best combined with cognitive restructuring.",
	},
	"relapse_prevention": {
		"title": "【复发预防】", "title_en": "[Relapse Prevention]",
		"text": "治疗结束时，帮助患者制定复发预防计划很重要。\n包括：1.识别早期预警信号 2.回顾有效的应对策略 3.知道何时寻求帮助\n这是CBT治疗的重要环节。",
		"text_en": "At the end of therapy, helping patients create a relapse prevention plan is important.\nIncludes: 1. Identify early warning signs 2. Review effective coping strategies 3. Know when to seek help\nThis is an important part of CBT therapy.",
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
		var title_key := "title_en" if I18n.is_en() else "title"
		var text_key := "text_en" if I18n.is_en() else "text"
		tutorial_shown.emit(tid, data.get(title_key, data.get("title", "")), data.get(text_key, data.get("text", "")))

func dismiss_current():
	GameManager.save_game()
	_show_next()

func force_show(tutorial_id: String):
	if _tutorials.has(tutorial_id):
		var data: Dictionary = _tutorials[tutorial_id]
		var title_key := "title_en" if I18n.is_en() else "title"
		var text_key := "text_en" if I18n.is_en() else "text"
		tutorial_shown.emit(tutorial_id, data.get(title_key, data.get("title", "")), data.get(text_key, data.get("text", "")))
