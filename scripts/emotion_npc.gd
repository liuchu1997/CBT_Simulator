extends "res://scripts/npc_base.gd"

@export var emotion_type: String = "anger"

var _teaching_data := {
	"anger": {
		"intro": "我是小怒！我代表【愤怒】这种情绪。\n愤怒不一定是坏事，但如果用认知扭曲来看待引发愤怒的事件，就会变得更难处理。",
		"intro_en": "I'm Anger! I represent the emotion of [Anger].\nAnger isn't always bad, but if you view anger-triggering events through cognitive distortions, it becomes harder to manage.",
		"scenario": "场景：同事在会议上打断了你的发言，你非常生气。\n以下哪种想法是'认知扭曲'？",
		"scenario_en": "Scenario: A colleague interrupts you in a meeting, and you're very angry.\nWhich of these thoughts is a 'cognitive distortion'?",
		"choices": [
			{"text": "他一定是故意针对我！（读心术）", "text_en": "He must be targeting me on purpose! (Mind Reading)", "correct": true, "explain": "对！这是'读心术'——你无法知道别人的真实意图。", "explain_en": "Correct! This is 'Mind Reading' — you can't know others' true intentions."},
			{"text": "他可能只是太着急表达自己的想法。", "text_en": "He might just be eager to share his thoughts.", "correct": false, "explain": "这是比较客观的看法，不是认知扭曲。", "explain_en": "This is a relatively objective view, not a cognitive distortion."},
			{"text": "他从来不尊重我！（过度概括）", "text_en": "He never respects me! (Overgeneralization)", "correct": true, "explain": "对！这是'过度概括'——一次事件不等于'从来不'。", "explain_en": "Correct! This is 'Overgeneralization' — one event doesn't mean 'never'."},
		],
		"reward": "很好！你学会了识别愤怒中的认知扭曲。\n记住：愤怒本身没有错，但扭曲的想法会让愤怒升级。",
		"reward_en": "Great! You've learned to identify cognitive distortions in anger.\nRemember: Anger itself isn't wrong, but distorted thoughts escalate it.",
	},
	"sadness": {
		"intro": "我是小忧！我代表【悲伤】这种情绪。\n悲伤的时候，我们容易出现'心理过滤'——只关注消极的，忽略积极的。",
		"intro_en": "I'm Sadness! I represent the emotion of [Sadness].\nWhen sad, we tend to use 'Mental Filtering' — focusing only on the negative, ignoring the positive.",
		"scenario": "场景：你完成了一个项目，领导说'整体不错，但细节还需要改进'。\n你只记住了'需要改进'。这是什么认知扭曲？",
		"scenario_en": "Scenario: You completed a project. Your boss says 'Overall good, but details need improvement.'\nYou only remember 'need improvement'. What distortion is this?",
		"choices": [
			{"text": "心理过滤——只关注消极的部分", "text_en": "Mental Filtering — only focusing on the negative", "correct": true, "explain": "完全正确！你过滤掉了'整体不错'的积极评价。", "explain_en": "Exactly right! You filtered out the positive 'overall good' feedback."},
			{"text": "这不算扭曲，确实需要改进", "text_en": "Not a distortion — it really needs improvement", "correct": false, "explain": "需要改进是真的，但忽略'整体不错'就是心理过滤。", "explain_en": "Improvement is needed, but ignoring 'overall good' IS mental filtering."},
		],
		"reward": "很好！你学会了识别心理过滤。\n试着在悲伤时列出今天发生的三件好事，对抗这种过滤。",
		"reward_en": "Great! You've learned to identify mental filtering.\nTry listing three good things today when feeling sad, to counter this filter.",
	},
	"fear": {
		"intro": "我是小恐！我代表【恐惧/焦虑】这种情绪。\n焦虑最常出现的认知扭曲是'灾难化'——把小问题想象成大灾难。",
		"intro_en": "I'm Fear! I represent the emotion of [Fear/Anxiety].\nThe most common cognitive distortion in anxiety is 'Catastrophizing' — imagining small problems as major disasters.",
		"scenario": "场景：你做了一个小失误，立刻想到'我肯定要被开除了'。\n下面哪个问题能帮助你打破灾难化思维？",
		"scenario_en": "Scenario: You made a small mistake and immediately think 'I'm definitely getting fired.'\nWhich question helps break catastrophizing?",
		"choices": [
			{"text": "最坏的结果是什么？它真的会发生吗？", "text_en": "What's the worst that could happen? Will it really happen?", "correct": true, "explain": "对！评估实际概率是打破灾难化的好方法。", "explain_en": "Correct! Evaluating actual probability is a great way to break catastrophizing."},
			{"text": "算了，不想了。", "text_en": "Forget it, I won't think about it.", "correct": false, "explain": "回避不能解决问题，下次还会出现同样的灾难化想法。", "explain_en": "Avoidance doesn't solve the problem. The same catastrophic thoughts will return."},
			{"text": "如果真的发生了，我能怎么应对？", "text_en": "If it did happen, how could I cope?", "correct": true, "explain": "对！制定应对计划可以降低灾难化带来的焦虑。", "explain_en": "Correct! Making a coping plan can reduce catastrophizing anxiety."},
		],
		"reward": "很好！你学会了对抗灾难化思维。\n记住：问自己'这真的会发生吗？概率有多大？'",
		"reward_en": "Great! You've learned to counter catastrophizing.\nRemember: Ask yourself 'Will this really happen? What's the probability?'",
	},
	"joy": {
		"intro": "我是小悦！我代表【快乐】这种情绪。\n你知道吗？积极的认知习惯也能帮我们保持好心情！",
		"intro_en": "I'm Joy! I represent the emotion of [Joy].\nDid you know? Positive cognitive habits can help us maintain good moods!",
		"scenario": "场景：你今天过得很开心，但脑子里突然冒出'这种好日子不会持续'的想法。\n这属于什么认知扭曲？",
		"scenario_en": "Scenario: You're having a great day, but suddenly think 'These good days won't last.'\nWhat cognitive distortion is this?",
		"choices": [
			{"text": "灾难化——预见最坏的结果", "text_en": "Catastrophizing — predicting the worst outcome", "correct": true, "explain": "没错！即使在开心的时候，灾难化也会偷走你的快乐。", "explain_en": "Right! Even during happy moments, catastrophizing can steal your joy."},
			{"text": "这很正常，没什么问题", "text_en": "This is normal, nothing wrong", "correct": false, "explain": "虽然常见，但这确实是一种自动化的消极思维。", "explain_en": "Although common, this IS an automatic negative thought pattern."},
		],
		"reward": "很好！你学会了在积极时刻也能识别认知扭曲。\n试着享受当下的快乐，而不是担心它什么时候会消失。",
		"reward_en": "Great! You've learned to identify distortions even in positive moments.\nTry enjoying present happiness instead of worrying when it will end.",
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
	
	var is_en := I18n.is_en() if I18n else false
	var intro_text: String = data.get("intro_en", data.get("intro", "")) if is_en else data.get("intro", "")
	var scenario_text: String = data.get("scenario_en", data.get("scenario", "")) if is_en else data.get("scenario", "")
	var reward_text: String = data.get("reward_en", data.get("reward", "")) if is_en else data.get("reward", "")
	
	var dialogue: Array[Dictionary] = []
	dialogue.append({"speaker": npc_name, "text": intro_text})
	dialogue.append({"speaker": npc_name, "text": scenario_text})
	
	var choices_for_dialogue: Array = []
	for i in range(_current_choices.size()):
		var c: Dictionary = _current_choices[i]
		var choice_text: String = c.get("text_en", c.get("text", "")) if is_en else c.get("text", "")
		var explain_text: String = c.get("explain_en", c.get("explain", "")) if is_en else c.get("explain", "")
		choices_for_dialogue.append({
			"text": choice_text,
			"feedback": explain_text,
			"id": "emotion_%s_c%d" % [emotion_type, i],
		})
	dialogue.append({"choices": choices_for_dialogue})
	dialogue.append({"speaker": npc_name, "text": reward_text})
	
	DialogueManager.start_dialogue(dialogue)
	GameManager.learn_strategy("emotion_%s" % emotion_type)
