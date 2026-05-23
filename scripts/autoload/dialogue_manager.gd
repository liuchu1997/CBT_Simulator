extends Node

signal dialogue_started
signal dialogue_finished
signal text_displayed(speaker: String, text: String)
signal choices_displayed(choices: Array)
signal choice_selected(choice_id: String)

var _is_active: bool = false
var _current_queue: Array[Dictionary] = []
var _current_index: int = 0
var _on_finished_callback: Callable
var _start_frame: int = -1
var _interact_cooldown: int = 0

func is_active() -> bool:
	return _is_active

func is_same_start_frame() -> bool:
	return Engine.get_process_frames() == _start_frame

func is_on_cooldown() -> bool:
	return _interact_cooldown > 0

func _process(_delta: float):
	if _interact_cooldown > 0:
		_interact_cooldown -= 1

func start_dialogue(dialogue_data: Array[Dictionary], on_finished: Callable = Callable()):
	if _is_active:
		return
	_is_active = true
	_current_queue = dialogue_data
	_current_index = 0
	_on_finished_callback = on_finished
	_start_frame = Engine.get_process_frames()
	dialogue_started.emit()
	_process_next()

func _process_next():
	if _current_index >= _current_queue.size():
		_end_dialogue()
		return
	
	var entry: Dictionary = _current_queue[_current_index]
	_current_index += 1
	
	if entry.has("speaker") and entry.has("text"):
		text_displayed.emit(entry["speaker"], entry["text"])
	elif entry.has("choices"):
		choices_displayed.emit(entry["choices"])

func advance():
	if not _is_active:
		return
	if is_same_start_frame():
		return
	_process_next()

func select_choice(index: int):
	if not _is_active:
		return
	var entry: Dictionary = _current_queue[_current_index - 1]
	if not entry.has("choices"):
		return
	var choices: Array = entry["choices"]
	if index < 0 or index >= choices.size():
		return
	
	var choice: Dictionary = choices[index]
	choice_selected.emit(choice.get("id", ""))
	if choice.has("score_category"):
		var pts: int = choice.get("score_points", 0)
		var category: String = choice["score_category"]
		var pid: String = GameManager.current_patient_id
		
		var battle_result: Dictionary = {}
		var effectiveness_label: String = ""
		if BattleEngine and BattleEngine.get_patient_data(pid).size() > 0:
			battle_result = BattleEngine.apply_skill(pid, category, pts)
			pts = battle_result.get("actual_points", pts)
			effectiveness_label = battle_result.get("effectiveness_label", "")
		
		ScoringSystem.log_choice(
			choice.get("id", ""),
			category,
			pts,
			choice.get("feedback", ""),
			effectiveness_label,
		)
		if pts > 0:
			var bond_mod: int = mini(pts, 5) + SkillTree.get_bond_bonus()
			GameManager.modify_bond(pid, bond_mod)
			CbtTutorial._on_trigger("first_good_choice")
		elif pts < 0:
			GameManager.modify_bond(pid, maxi(pts, -5))
			CbtTutorial._on_trigger("first_bad_choice")
	
	if choice.has("next"):
		_jump_to(choice["next"])
	else:
		_process_next()

func _jump_to(label_name: String):
	for i in range(_current_index, _current_queue.size()):
		if _current_queue[i].get("label", "") == label_name:
			_current_index = i
			_process_next()
			return
	_process_next()

func _end_dialogue():
	_is_active = false
	_current_queue.clear()
	_current_index = 0
	_interact_cooldown = 5
	dialogue_finished.emit()
	if _on_finished_callback.is_valid():
		_on_finished_callback.call()
