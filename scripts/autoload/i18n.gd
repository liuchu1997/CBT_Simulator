extends Node

signal language_changed(lang: String)

var current_lang: String = "zh"

const ZH := "zh"
const EN := "en"

var _db: Dictionary = {}

func _ready():
	_init_db()

func set_language(lang: String):
	if lang == current_lang:
		return
	current_lang = lang
	language_changed.emit(lang)

func is_en() -> bool:
	return current_lang == EN

func t(key: String) -> String:
	var entry: Dictionary = _db.get(key, {})
	var text: String = entry.get(current_lang, entry.get(ZH, key))
	return text

func _s(key: String, args: Array = []) -> String:
	var text: String = t(key)
	for i in range(args.size()):
		text = text.replace("{%d}" % i, str(args[i]))
	return text

func _init_db():
	_db = {
		"game_title": {"zh": "CBT心理治疗模拟器", "en": "CBT Therapy Simulator"},
		"start_game": {"zh": "开始游戏", "en": "Start Game"},
		"reset_game": {"zh": "重新开始", "en": "Reset Game"},
		"confirm_reset": {"zh": "确认重置？", "en": "Confirm Reset?"},
		"resume_game": {"zh": "继续游戏", "en": "Resume"},
		"back_to_menu": {"zh": "返回主菜单", "en": "Main Menu"},
		"save_game": {"zh": "保存游戏", "en": "Save Game"},
		"saved": {"zh": "已保存!", "en": "Saved!"},
		"pause": {"zh": "暂停", "en": "Paused"},
		"close": {"zh": "关闭", "en": "Close"},
		"continue_label": {"zh": "继续", "en": "Continue"},
		"ok_got_it": {"zh": "知道了", "en": "Got It"},
		
		"therapist_level": {"zh": "治疗师等级", "en": "Therapist Level"},
		"total_score": {"zh": "总积分", "en": "Total Score"},
		"chapter_label": {"zh": "章节", "en": "Chapter"},
		"skill_points": {"zh": "技能点", "en": "Skill Points"},
		
		"chapter_1_title": {"zh": "第一章：初入诊室", "en": "Chapter 1: First Session"},
		"chapter_2_title": {"zh": "第二章：焦虑的面具", "en": "Chapter 2: Mask of Anxiety"},
		"chapter_3_title": {"zh": "第三章：自我归因", "en": "Chapter 3: Self-Attribution"},
		"chapter_final_title": {"zh": "终章：治疗师的成长", "en": "Final: Therapist's Growth"},
		
		"patient_lin_xiaoyu": {"zh": "林小雨", "en": "Lin Xiaoyu"},
		"patient_zhang_hao": {"zh": "张浩", "en": "Zhang Hao"},
		"patient_wang_mei": {"zh": "王美", "en": "Wang Mei"},
		"receptionist": {"zh": "前台小李", "en": "Receptionist Li"},
		
		"diagnosis_depression": {"zh": "中度抑郁", "en": "Moderate Depression"},
		"diagnosis_gad": {"zh": "广泛性焦虑", "en": "Generalized Anxiety"},
		"diagnosis_social_anxiety": {"zh": "社交焦虑", "en": "Social Anxiety"},
		
		"emotion_depression": {"zh": "抑郁", "en": "Depression"},
		"emotion_anxiety": {"zh": "焦虑", "en": "Anxiety"},
		"emotion_anger": {"zh": "愤怒", "en": "Anger"},
		"emotion_hope": {"zh": "希望", "en": "Hope"},
		
		"emotion_anger_npc": {"zh": "小怒", "en": "Anger"},
		"emotion_sadness_npc": {"zh": "小忧", "en": "Sadness"},
		"emotion_fear_npc": {"zh": "小恐", "en": "Fear"},
		"emotion_joy_npc": {"zh": "小悦", "en": "Joy"},
		
		"state_active": {"zh": "活跃", "en": "Active"},
		"state_recovering": {"zh": "恢复中", "en": "Recovering"},
		"state_resilient": {"zh": "有韧性", "en": "Resilient"},
		"state_guarded": {"zh": "防御", "en": "Guarded"},
		"state_probing": {"zh": "试探", "en": "Probing"},
		"state_opening_up": {"zh": "敞开心扉", "en": "Opening Up"},
		"state_flooded": {"zh": "情绪泛滥", "en": "Emotionally Flooded"},
		"state_resistant": {"zh": "抗拒", "en": "Resistant"},
		"state_reflecting": {"zh": "反思", "en": "Reflecting"},
		"state_insight": {"zh": "领悟", "en": "Insight"},
		"state_unknown": {"zh": "未知", "en": "Unknown"},
		"state_no_state": {"zh": "无状态", "en": "None"},
		"state_initial_assess": {"zh": "初始评估中", "en": "Initial Assessment"},
		
		"skill_cognitive": {"zh": "认知重构", "en": "Cognitive Restructuring"},
		"skill_behavioral": {"zh": "行为激活", "en": "Behavioral Activation"},
		"skill_empathic": {"zh": "共情倾听", "en": "Empathic Listening"},
		"skill_identify_distortion": {"zh": "辨识扭曲", "en": "Identify Distortions"},
		"skill_socratic": {"zh": "苏格拉底提问", "en": "Socratic Questioning"},
		"skill_thought_record": {"zh": "思维记录", "en": "Thought Records"},
		"skill_activity_schedule": {"zh": "活动安排", "en": "Activity Scheduling"},
		"skill_exposure": {"zh": "暴露疗法", "en": "Exposure Therapy"},
		"skill_behavior_exp": {"zh": "行为实验", "en": "Behavioral Experiments"},
		"skill_mindfulness": {"zh": "正念行动", "en": "Mindful Action"},
		"skill_active_listening": {"zh": "积极倾听", "en": "Active Listening"},
		"skill_emotion_reflect": {"zh": "情感反映", "en": "Emotion Reflection"},
		"skill_unconditional": {"zh": "无条件接纳", "en": "Unconditional Acceptance"},
		"skill_alliance": {"zh": "治疗联盟", "en": "Therapeutic Alliance"},
		
		"dimension_empathy": {"zh": "共情能力", "en": "Empathy"},
		"dimension_listening": {"zh": "积极倾听", "en": "Active Listening"},
		"dimension_socratic": {"zh": "苏格拉底式提问", "en": "Socratic Questioning"},
		"dimension_cognitive": {"zh": "认知重构", "en": "Cognitive Restructuring"},
		"dimension_relationship": {"zh": "治疗关系", "en": "Therapeutic Relationship"},
		
		"grade_general": {"zh": "一般", "en": "Average"},
		"effectiveness_super": {"zh": "效果拔群！", "en": "Super Effective!"},
		"effectiveness_great": {"zh": "很有效！", "en": "Very Effective!"},
		"effectiveness_normal": {"zh": "一般...", "en": "Normal..."},
		"effectiveness_weak": {"zh": "效果不佳...", "en": "Not Very Effective..."},
		"effectiveness_none": {"zh": "完全无效！", "en": "No Effect!"},
		
		"room_lobby": {"zh": "大厅", "en": "Lobby"},
		"room_anxiety": {"zh": "焦虑系诊室", "en": "Anxiety Therapy Room"},
		"room_depression": {"zh": "抑郁系诊室", "en": "Depression Therapy Room"},
		"room_personality": {"zh": "人格系诊室", "en": "Personality Therapy Room"},
		"room_crisis": {"zh": "危机干预室", "en": "Crisis Intervention Room"},
		
		"select_response": {"zh": "请选择回应", "en": "Choose Response"},
		"space_continue": {"zh": "[ 空格 继续 ]", "en": "[ Space Continue ]"},
		"space_interact": {"zh": "[ 空格 ] 互动", "en": "[ Space ] Interact"},
		"space_talk": {"zh": "[ 空格 ] 对话", "en": "[ Space ] Talk"},
		"space_talk_to": {"zh": "[ 空格 ] 与 %s 对话", "en": "[ Space ] Talk to %s"},
		"interact_hint": {"zh": "[ 空格 ] 互动", "en": "[ Space ] Interact"},
		"requires_skill": {"zh": "需要 %s Lv.%d", "en": "Requires %s Lv.%d"},
		
		"score_report_title": {"zh": "治疗评分报告", "en": "Therapy Score Report"},
		"score_patient": {"zh": "患者", "en": "Patient"},
		"score_grade": {"zh": "评级", "en": "Grade"},
		"score_total": {"zh": "总分", "en": "Total"},
		"score_details": {"zh": "评分明细", "en": "Score Details"},
		"score_feedback": {"zh": "反馈", "en": "Feedback"},
		"score_continue": {"zh": "继续 [空格]", "en": "Continue [Space]"},
		"score_alliance": {"zh": "治疗联盟", "en": "Therapeutic Alliance"},
		"score_emotion_state": {"zh": "情绪状态", "en": "Emotional State"},
		"score_skill_effect": {"zh": "技能效果", "en": "Skill Effect"},
		"score_chapter_pass": {"zh": "章节要求: 通过", "en": "Chapter Requirement: Passed"},
		"score_chapter_fail": {"zh": "章节要求: 未通过", "en": "Chapter Requirement: Not Met"},
		
		"journal_title": {"zh": "治疗日志", "en": "Therapy Journal"},
		"journal_count": {"zh": "治疗次数", "en": "Sessions"},
		"journal_strategies": {"zh": "已学策略", "en": "Learned Strategies"},
		"journal_empty": {"zh": "暂无日志记录", "en": "No journal entries yet"},
		
		"profile_title": {"zh": "患者档案", "en": "Patient Profile"},
		"profile_name": {"zh": "患者姓名", "en": "Patient Name"},
		"profile_diagnosis": {"zh": "诊断", "en": "Diagnosis"},
		"profile_emotion": {"zh": "情绪状态", "en": "Emotional State"},
		"profile_distortion": {"zh": "认知扭曲", "en": "Cognitive Distortions"},
		"profile_records": {"zh": "治疗记录", "en": "Treatment Records"},
		"profile_trust": {"zh": "信任度", "en": "Trust Level"},
		
		"skill_tree_title": {"zh": "CBT 技能树", "en": "CBT Skill Tree"},
		"skill_points_label": {"zh": "技能点", "en": "Skill Points"},
		"skill_upgrade": {"zh": "升级", "en": "Upgrade"},
		"skill_maxed": {"zh": "已满级", "en": "Maxed"},
		
		"achievement_unlocked": {"zh": "成就解锁！", "en": "Achievement Unlocked!"},
		"ach_first_session": {"zh": "初次问诊", "en": "First Session"},
		"ach_first_session_d": {"zh": "完成第一次治疗", "en": "Complete your first session"},
		"ach_five_sessions": {"zh": "经验丰富", "en": "Experienced"},
		"ach_five_sessions_d": {"zh": "完成5次治疗", "en": "Complete 5 sessions"},
		"ach_perfect": {"zh": "完美治疗", "en": "Perfect Therapy"},
		"ach_perfect_d": {"zh": "获得S级评分", "en": "Get an S grade"},
		"ach_cognitive": {"zh": "认知大师", "en": "Cognitive Master"},
		"ach_cognitive_d": {"zh": "认知技能升到满级", "en": "Max cognitive skill"},
		"ach_behavioral": {"zh": "行为专家", "en": "Behavioral Expert"},
		"ach_behavioral_d": {"zh": "行为技能升到满级", "en": "Max behavioral skill"},
		"ach_empathic": {"zh": "共情之师", "en": "Empathic Master"},
		"ach_empathic_d": {"zh": "共情技能升到满级", "en": "Max empathic skill"},
		"ach_all_master": {"zh": "全能治疗师", "en": "All-Round Therapist"},
		"ach_all_master_d": {"zh": "所有技能满级", "en": "Max all skills"},
		"ach_trust_50": {"zh": "获得信任", "en": "Trust Earned"},
		"ach_trust_50_d": {"zh": "患者信任度达到50", "en": "Reach trust level 50"},
		"ach_trust_80": {"zh": "深度联结", "en": "Deep Connection"},
		"ach_trust_80_d": {"zh": "患者信任度达到80", "en": "Reach trust level 80"},
		"ach_resilient": {"zh": "一线希望", "en": "Glimmer of Hope"},
		"ach_resilient_d": {"zh": "帮助患者达到韧性状态", "en": "Help a patient reach resilient state"},
		"ach_breakthrough": {"zh": "突破", "en": "Breakthrough"},
		"ach_breakthrough_d": {"zh": "高信任度+韧性状态", "en": "High trust + resilient state"},
		"ach_unlock_zhang": {"zh": "新患者", "en": "New Patient"},
		"ach_unlock_zhang_d": {"zh": "解锁张浩", "en": "Unlock Zhang Hao"},
		"ach_unlock_wang": {"zh": "更多患者", "en": "More Patients"},
		"ach_unlock_wang_d": {"zh": "解锁王美", "en": "Unlock Wang Mei"},
		
		"chapter_complete": {"zh": "章节完成！", "en": "Chapter Complete!"},
		"congratulations": {"zh": "恭喜！", "en": "Congratulations!"},
		"chapter_unlock_next": {"zh": "解锁下一章节！", "en": "Next chapter unlocked!"},
		
		"task_current": {"zh": "当前任务", "en": "Current Task"},
		"task_explore": {"zh": "探索诊室，与角色对话", "en": "Explore the clinic, talk to characters"},
		"task_free_explore": {"zh": "自由探索", "en": "Free Explore"},
		"task_treatment_progress": {"zh": "治疗进度", "en": "Treatment Progress"},
		"task_treatment_tips": {"zh": "治疗提示", "en": "Treatment Tips"},
		"task_chapter_info": {"zh": "章节信息", "en": "Chapter Info"},
		"task_patient_status": {"zh": "患者状态", "en": "Patient Status"},
		"task_treatment_hint": {"zh": "治疗提示", "en": "Treatment Hints"},
		"task_hotkeys": {"zh": "快捷键", "en": "Hotkeys"},
		"task_not_unlocked": {"zh": "未解锁", "en": "Locked"},
		"task_completed": {"zh": "治疗完成", "en": "Treatment Complete"},
		
		"tutorial_welcome": {"zh": "欢迎来到CBT心理治疗模拟器！", "en": "Welcome to CBT Therapy Simulator!"},
		"tutorial_role": {"zh": "你将扮演一名CBT认知行为治疗师，帮助患者识别和改变负面思维模式。", "en": "You play as a CBT therapist, helping patients identify and change negative thought patterns."},
		"tutorial_move": {"zh": "使用WASD或方向键移动，空格键与NPC互动。", "en": "Use WASD or arrow keys to move, Space to interact with NPCs."},
		"tutorial_dialogue": {"zh": "对话中选择不同的回应方式，你的选择会影响治疗效果。", "en": "Choose different responses in dialogue. Your choices affect therapy outcomes."},
		"tutorial_scoring": {"zh": "每次治疗会从5个维度评分：共情能力、积极倾听、苏格拉底式提问、认知重构、治疗关系。", "en": "Each session is scored on 5 dimensions: Empathy, Active Listening, Socratic Questioning, Cognitive Restructuring, Therapeutic Relationship."},
		"tutorial_task": {"zh": "当前任务会显示在顶部，按T键查看详细任务面板。", "en": "Current task is shown at the top. Press T for detailed task panel."},
		"tutorial_start": {"zh": "走近角色，按空格键开始你的第一次治疗！", "en": "Walk up to a character and press Space to start your first session!"},
		
		"hint_interact": {"zh": "走近角色按空格对话", "en": "Walk to a character and press Space"},
		"hint_task": {"zh": "按T查看任务", "en": "Press T for tasks"},
		"hint_skills": {"zh": "K技能", "en": "K Skills"},
		"hint_retry": {"zh": "再次治疗争取更好评分", "en": "Try again for a better score"},
		"hint_treatment_progress": {"zh": "治疗进度", "en": "Progress"},
		"hint_not_passed": {"zh": "章节未通过", "en": "Chapter not passed"},
		
		"grade_below_requirement": {"zh": "评级不达标", "en": "Grade below requirement"},
		"grade_need_above": {"zh": "需要达到%s级，最低评级为%s级", "en": "Need %s grade or above, lowest was %s"},
		"grade_requirement": {"zh": "需要%s级以上，有治疗评级为%s级", "en": "Need %s grade or above, got %s"},
		
		"battle_patient": {"zh": "患者", "en": "Patient"},
		"battle_alliance": {"zh": "治疗联盟", "en": "Alliance"},
		"battle_emotion": {"zh": "情绪", "en": "Emotion"},
		"battle_defense": {"zh": "防御", "en": "Defense"},
		"battle_turn": {"zh": "回合", "en": "Turn"},
		"battle_insight": {"zh": "洞察", "en": "Insight"},
		"battle_avoidance": {"zh": "回避", "en": "Avoidance"},
		"battle_schema_discovered": {"zh": "发现核心信念", "en": "Core Belief Discovered"},
		
		"cbt_cognitive_triangle": {"zh": "认知三角：思维→情绪→行为互相影响", "en": "Cognitive Triangle: Thoughts→Emotions→Behaviors influence each other"},
		"cbt_homework": {"zh": "家庭作业是CBT的核心组成部分", "en": "Homework is a core component of CBT"},
		"cbt_behavioral_activation": {"zh": "行为激活：通过增加愉悦活动改善情绪", "en": "Behavioral Activation: Improve mood through pleasant activities"},
		"cbt_relaxation": {"zh": "放松训练：4-7-8呼吸法", "en": "Relaxation: 4-7-8 Breathing Technique"},
		"cbt_relapse_prevention": {"zh": "复发预防：识别早期预警信号", "en": "Relapse Prevention: Identify early warning signs"},
		
		"reset_warning": {"zh": "重置后所有进度将丢失！", "en": "All progress will be lost after reset!"},
		"lang_switch": {"zh": "English", "en": "中文"},
		"version": {"zh": "v1.0", "en": "v1.0"},
		
		"tip_empathy": {"zh": "尝试更多地反映患者的情感，让他们感到被理解。", "en": "Try to reflect the patient's emotions more to make them feel understood."},
		"tip_listening": {"zh": "多使用开放式问题，让患者充分表达。", "en": "Use more open-ended questions to let the patient express fully."},
		"tip_socratic": {"zh": "尝试用提问引导患者自己发现思维中的不合理之处。", "en": "Guide the patient to discover irrational thoughts through questioning."},
		"tip_cognitive": {"zh": "帮助患者识别认知扭曲，并引导他们找到替代的合理想法。", "en": "Help identify cognitive distortions and find alternative rational thoughts."},
		"tip_rapport": {"zh": "注意建立信任关系，不要急于给建议。", "en": "Build trust first, don't rush to give advice."},
		"tip_excellent": {"zh": "表现出色！继续保持这种专业的治疗风格。", "en": "Excellent! Keep up the professional therapy style."},
		
		"tip_lin": {"zh": "林小雨需要温和的共情和逐步的认知引导", "en": "Lin Xiaoyu needs gentle empathy and gradual cognitive guidance"},
		"tip_zhang": {"zh": "张浩需要先建立信任，再逐步挑战焦虑思维", "en": "Zhang Hao needs trust first, then gradually challenge anxious thoughts"},
		"tip_wang": {"zh": "王美需要帮助区分责任归属，减少自我归因", "en": "Wang Mei needs help distinguishing responsibility, reducing self-blame"},
		
		"depression_room": {"zh": "抑郁系诊室", "en": "Depression Therapy Room"},
		"anxiety_room": {"zh": "焦虑系诊室", "en": "Anxiety Therapy Room"},
		"personality_room": {"zh": "人格系诊室", "en": "Personality Therapy Room"},
		"crisis_room": {"zh": "危机干预室", "en": "Crisis Intervention Room"},
		
		"recep_welcome": {"zh": "欢迎来到心理治疗中心！我是前台小李，有问题随时来找我。", "en": "Welcome to the Therapy Center! I'm Li, the receptionist. Come to me anytime!"},
		"recep_first_guide": {"zh": "林小雨在左上方的诊室A等你。走近她，按空格键开始治疗吧！", "en": "Lin Xiaoyu is waiting in Room A (upper left). Walk to her and press Space to start!"},
		"recep_first_tip": {"zh": "小提示：倾听和共情是打开患者心扉的关键，不要急着给建议哦。", "en": "Tip: Listening and empathy are key to opening up patients. Don't rush to give advice."},
		"recep_stuck_intro": {"zh": "看起来你遇到了一些困难...", "en": "Looks like you're having some difficulties..."},
		"recep_stuck_help": {"zh": "你需要什么帮助？", "en": "How can I help you?"},
		"recep_stuck_skill": {"zh": "当前章节技能等级不足：\n%s\n按 K 键升级技能树。", "en": "Skill level insufficient for current chapter:\n%s\nPress K to upgrade skill tree."},
		"recep_stuck_grade": {"zh": "你已做了 %d 次治疗，但%s。", "en": "You've done %d sessions, but %s."},
		"recep_stuck_many": {"zh": "你已经做了很多次治疗，但章节仍未通过。可能需要调整策略。", "en": "You've done many sessions but the chapter isn't passed. Try adjusting your approach."},
		"recep_choice_tips": {"zh": "给我一些治疗技巧", "en": "Give me therapy tips"},
		"recep_choice_reset_patient": {"zh": "重置当前患者的治疗记录", "en": "Reset current patient's records"},
		"recep_choice_reset_all": {"zh": "重置全部游戏进度", "en": "Reset all game progress"},
		"recep_choice_retry": {"zh": "不用了，我再试试", "en": "No thanks, I'll try again"},
		"recep_choice_task": {"zh": "当前任务是什么？", "en": "What's the current task?"},
		"recep_choice_advice": {"zh": "给我一些治疗建议", "en": "Give me therapy advice"},
		"recep_choice_bye": {"zh": "谢谢，我继续去了", "en": "Thanks, I'll keep going"},
		"recep_choice_confirm": {"zh": "确认重置", "en": "Confirm reset"},
		"recep_choice_cancel": {"zh": "算了", "en": "Never mind"},
		"recep_rp_confirm": {"zh": "确定要重置当前患者的治疗记录吗？你会从头开始治疗这位患者。", "en": "Reset this patient's therapy records? You'll start over with this patient."},
		"recep_rp_done": {"zh": "好的，治疗记录已清除。去重新找患者开始治疗吧！", "en": "Done, records cleared. Go find the patient and start fresh!"},
		"recep_ra_confirm": {"zh": "确定要重置全部进度吗？所有治疗记录、技能和成就都会清零！", "en": "Reset ALL progress? All records, skills and achievements will be lost!"},
		"recep_ra_done": {"zh": "全部进度已清除。欢迎重新开始治疗师之旅！", "en": "All progress cleared. Welcome to a fresh start!"},
		"recep_encourage": {"zh": "好的，继续加油！", "en": "Keep it up!"},
		"recep_go_tip": {"zh": "好的！记住：先共情倾听，再引导反思。你一定可以的！", "en": "Remember: empathize first, then guide reflection. You can do it!"},
		"recep_all_done": {"zh": "你已经完成了所有章节！", "en": "You've completed all chapters!"},
		"recep_final_chapter": {"zh": "你已经走到最后了，加油！", "en": "You've reached the final chapter. Go for it!"},
		"recep_go_find": {"zh": "去找%s开始治疗吧，她在%s。", "en": "Go find %s to start therapy. Location: %s."},
		"recep_continue": {"zh": "继续和%s对话，还剩 %d 次治疗。", "en": "Continue with %s. %d sessions remaining."},
		"recep_enough": {"zh": "%s的治疗次数已够。如果评级不够，可以继续追加治疗。", "en": "%s has enough sessions. If grade is insufficient, you can do more."},
		"recep_room_a": {"zh": "左上方诊室A", "en": "Room A (upper left)"},
		"recep_room_b": {"zh": "右上方诊室B", "en": "Room B (upper right)"},
		"recep_room_c": {"zh": "左下方", "en": "Lower left area"},
		"recep_room_default": {"zh": "诊室", "en": "Therapy room"},
		"recep_task_chapter": {"zh": "当前章节：", "en": "Current chapter: "},
		"recep_task_patient": {"zh": "目标患者：", "en": "Target patient: "},
		"recep_task_progress": {"zh": "治疗进度：", "en": "Progress: "},
		"recep_task_grade_req": {"zh": "评级要求：最低 ", "en": "Grade requirement: minimum "},
		"recep_skill_warning": {"zh": "注意：技能等级不足！按K键升级技能树。", "en": "Warning: Skill level insufficient! Press K to upgrade."},
		"recep_bye_msg": {"zh": "加油！有问题随时来找我。", "en": "Keep going! Come to me if you need help."},
		"recep_tip_lin": {"zh": "林小雨有抑郁倾向，常常'非黑即白'地看问题。\n\n要点：\n1. 先倾听和共情，让她感到被理解\n2. 用提问引导她检视消极想法的证据\n3. 不要直接否定感受——'别这么想'会适得其反\n4. 她防御时用反映和确认来'破防'", "en": "Lin Xiaoyu has depression with 'all-or-nothing' thinking.\n\nTips:\n1. Listen and empathize first, make her feel understood\n2. Use questions to guide her to examine evidence for negative thoughts\n3. Don't dismiss feelings — 'don't think that way' backfires\n4. When guarded, use reflection and validation"},
		"recep_tip_zhang": {"zh": "张浩的问题是灾难化思维，总往最坏处想。\n\n要点：\n1. 用苏格拉底式提问检视担忧的现实基础\n2. 引导回忆'担心的结果有多少真正发生了'\n3. 认知链分析可系统性解构灾难化\n4. 不要说'想太多没用'——他不被理解会更焦虑", "en": "Zhang Hao has catastrophizing — always imagining the worst.\n\nTips:\n1. Use Socratic questioning to examine evidence for worries\n2. Guide him to recall how many worries actually came true\n3. Cognitive chain analysis can systematically deconstruct catastrophizing\n4. Don't say 'you worry too much' — feeling misunderstood increases anxiety"},
		"recep_tip_wang": {"zh": "王美倾向个人化，什么错都怪自己。\n\n要点：\n1. 帮她看到事情的多因性\n2. 双标准技术很有效：'如果是同事遇到呢？'\n3. 高级行为实验可用数据挑战信念\n4. 不要简单安慰'别怪自己'——要引导她自己发现", "en": "Wang Mei tends to personalize — blaming herself for everything.\n\nTips:\n1. Help her see multiple causes of events\n2. Double-standard technique: 'What if a colleague faced this?'\n3. Advanced behavioral experiments can challenge beliefs with data\n4. Don't just say 'don't blame yourself' — guide her to discover it herself"},
		"recep_tip_general": {"zh": "通用治疗技巧：\n\n1. 先共情倾听，不要急着给建议\n2. 用提问引导患者自己发现问题\n3. 患者防御时 → 用反映/确认技巧\n4. 患者反思时 → 用认知重构深入\n5. 按K键升级技能树，解锁高级选项", "en": "General therapy tips:\n\n1. Empathize first, don't rush to give advice\n2. Use questions to guide patients to discover issues themselves\n3. Patient guarded → Use reflection/validation\n4. Patient reflective → Use cognitive restructuring\n5. Press K to upgrade skill tree and unlock advanced options"},

		"hotkey_bar": {"zh": "T 任务 | K 技能树 | J 日志 | I 患者档案 | ESC 暂停", "en": "T Tasks | K Skills | J Journal | I Profile | ESC Pause"},
		"reset_confirm_text": {"zh": "再按一次确认重置（所有进度将丢失）", "en": "Press again to confirm (all progress will be lost)"},
		"dialogue_hint_default": {"zh": "[ 空格键继续 ]", "en": "[ Space to continue ]"},
		"got_it_space": {"zh": "知道了 [空格]", "en": "Got It [Space]"},
		"close_j": {"zh": "关闭[J]", "en": "Close[J]"},
		"close_t": {"zh": "关闭[T]", "en": "Close[T]"},
		"select_record_detail": {"zh": "选择一条记录查看详情", "en": "Select a record to view details"},
		"current_task_label": {"zh": "当前任务:", "en": "Current Task:"},
		"room_anxiety_label": {"zh": "— 焦虑系诊室 —", "en": "— Anxiety Therapy Room —"},
		"room_depression_label": {"zh": "— 抑郁系诊室 —", "en": "— Depression Therapy Room —"},
		"room_personality_label": {"zh": "— 人格系诊室 —", "en": "— Personality Therapy Room —"},
		"room_crisis_label": {"zh": "— 危机干预室 —", "en": "— Crisis Intervention Room —"},
		"room_anxiety_desc": {"zh": "[color=gray]温暖的橙色调房间。墙上挂着呼吸练习的图表。角落里有一个沙袋——行为激活的好帮手。[/color]", "en": "[color=gray]Warm orange room. Breathing exercise charts on the wall. A punching bag in the corner for behavioral activation.[/color]"},
		"room_depression_desc": {"zh": "[color=gray]这里光线柔和，墙壁是深蓝色调。书架上放着关于认知行为疗法的书籍。一张沙发和一把椅子面对面摆放着。[/color]", "en": "[color=gray]Soft lighting with deep blue walls. Bookshelves with CBT references. A sofa and chair face each other.[/color]"},
		"room_personality_desc": {"zh": "[color=gray]紫色调的安静房间。镜子和白板用于图式分析和归因训练。空气中有淡淡的薰衣草香。[/color]", "en": "[color=gray]Quiet purple room. Mirrors and whiteboards for schema analysis. A faint lavender scent in the air.[/color]"},
		"room_crisis_desc": {"zh": "[color=gray]红色警戒线标记的房间。一切设备都是最高级别的。这里需要你所有的技能和经验。[/color]", "en": "[color=gray]Red alert room. Top-tier equipment. Demands all your skills and experience.[/color]"},
	}
