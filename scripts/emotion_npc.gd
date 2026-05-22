extends "res://scripts/npc_base.gd"

@export var emotion_type: String = "anger"

var _teaching_data := {
	"anger": {
		"intro": "我是小怒！我代表【愤怒】这种情绪。\n愤怒不一定是坏事，但如果用认知扭曲来看待引发愤怒的事件，就会变得更难处理。",
		"scenario": "场景：同事在会议上打断了你的发言，你非常生气。\n以下哪种想法是'认知扭曲'？",
		"choices": [
			{"text": "他一定是故意针对我！（读心术）", "correct": true, "explain": "对！这是'读心术'——你无法知道别人的真实意图。"},
			{"text": "他可能只是太着急表达自己的想法。", "correct": false, "explain": "这是比较客观的看法，不是认知扭曲。"},
			{"text": "他从来不尊重我！（过度概括）", "correct": true, "explain": "对！这是'过度概括'——一次事件不等于'从来不'。"},
		],
		"reward": "很好！你学会了识别愤怒中的认知扭曲。\n记住：愤怒本身没有错，但扭曲的想法会让愤怒升级。",
	},
	"sadness": {
		"intro": "我是小忧！我代表【悲伤】这种情绪。\n悲伤的时候，我们容易出现'心理过滤'——只关注消极的，忽略积极的。",
		"scenario": "场景：你完成了一个项目，领导说'整体不错，但细节还需要改进'。\n你只记住了'需要改进'。这是什么认知扭曲？",
		"choices": [
			{"text": "心理过滤——只关注消极的部分", "correct": true, "explain": "完全正确！你过滤掉了'整体不错'的积极评价。"},
			{"text": "这不算扭曲，确实需要改进", "correct": false, "explain": "需要改进是真的，但忽略'整体不错'就是心理过滤。"},
		],
		"reward": "很好！你学会了识别心理过滤。\n试着在悲伤时列出今天发生的三件好事，对抗这种过滤。",
	},
	"fear": {
		"intro": "我是小恐！我代表【恐惧/焦虑】这种情绪。\n焦虑最常出现的认知扭曲是'灾难化'——把小问题想象成大灾难。",
		"scenario": "场景：你做了一个小失误，立刻想到'我肯定要被开除了'。\n下面哪个问题能帮助你打破灾难化思维？",
		"choices": [
			{"text": "最坏的结果是什么？它真的会发生吗？", "correct": true, "explain": "对！评估实际概率是打破灾难化的好方法。"},
			{"text": "算了，不想了。", "correct": false, "explain": "回避不能解决问题，下次还会出现同样的灾难化想法。"},
			{"text": "如果真的发生了，我能怎么应对？", "correct": true, "explain": "对！制定应对计划可以降低灾难化带来的焦虑。"},
		],
		"reward": "很好！你学会了对抗灾难化思维。\n记住：问自己'这真的会发生吗？概率有多大？'",
	},
	"joy": {
		"intro": "我是小悦！我代表【快乐】这种情绪。\n你知道吗？积极的认知习惯也能帮我们保持好心情！",
		"scenario": "场景：你今天过得很开心，但脑子里突然冒出'这种好日子不会持续'的想法。\n这属于什么认知扭曲？",
		"choices": [
			{"text": "灾难化——预见最坏的结果", "correct": true, "explain": "没错！即使在开心的时候，灾难化也会偷走你的快乐。"},
			{"text": "这很正常，没什么问题", "correct": false, "explain": "虽然常见，但这确实是一种自动化的消极思维。"},
		],
		"reward": "很好！你学会了在积极时刻也能识别认知扭曲。\n试着享受当下的快乐，而不是担心它什么时候会消失。",
	},
}

var _current_choices: Array = []
var _choice_index: int = 0
var _correct_count: int = 0

func on_interact():
	if not is_interactable:
		return
	_face_player()
	if DialogueManager.is_active():
		return
	_start_teaching()

func _start_teaching():
	var data: Dictionary = _teaching_data.get(emotion_type, {})
	if data.is_empty():
		_show_idle_dialogue()
		return
	
	_correct_count = 0
	_choice_index = 0
	_current_choices = data.get("choices", [])
	
	var dialogue: Array[Dictionary] = []
	dialogue.append({"speaker": npc_name, "text": data.get("intro", "")})
	dialogue.append({"speaker": npc_name, "text": data.get("scenario", "")})
	
	var choices_for_dialogue: Array = []
	for i in range(_current_choices.size()):
		var c: Dictionary = _current_choices[i]
		var is_correct: bool = c.get("correct", false)
		choices_for_dialogue.append({
			"text": c.get("text", ""),
			"score_category": "cognitive_restructuring",
			"score_points": 2 if is_correct else -1,
			"feedback": c.get("explain", ""),
			"id": "emotion_%s_c%d" % [emotion_type, i],
		})
	dialogue.append({"choices": choices_for_dialogue})
	dialogue.append({"speaker": npc_name, "text": data.get("reward", "")})
	
	DialogueManager.start_dialogue(dialogue)
	GameManager.learn_strategy("emotion_%s" % emotion_type)
