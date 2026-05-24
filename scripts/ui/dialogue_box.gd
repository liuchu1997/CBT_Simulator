extends Control

enum State { HIDDEN, TYPING, WAITING_FOR_INPUT, SHOWING_CHOICES }

@onready var panel: Panel = $Panel
@onready var speaker_label: Label = $Panel/MarginContainer/VBoxContainer/SpeakerLabel
@onready var text_label: RichTextLabel = $Panel/MarginContainer/VBoxContainer/DialogueText
@onready var choices_container: VBoxContainer = $Panel/MarginContainer/VBoxContainer/ChoicesContainer
@onready var continue_hint: Label = $Panel/MarginContainer/VBoxContainer/ContinueHint

var _state: State = State.HIDDEN
var _tween: Tween = null

func _ready():
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished)
	DialogueManager.text_displayed.connect(_on_text_displayed)
	DialogueManager.choices_displayed.connect(_on_choices_displayed)
	visible = false
	continue_hint.visible = false
	speaker_label.text = I18n.t("battle_patient")
	text_label.text = ""
	continue_hint.text = I18n.t("dialogue_hint_default")
	I18n.language_changed.connect(func(_l):
		if not visible:
			speaker_label.text = I18n.t("battle_patient")
			continue_hint.text = I18n.t("dialogue_hint_default")
	)

func _input(event: InputEvent):
	if _state == State.HIDDEN:
		return
	if not event.is_action_pressed("interact"):
		return
	
	match _state:
		State.TYPING:
			_finish_typing()
		State.WAITING_FOR_INPUT:
			DialogueManager.advance()

func _on_dialogue_started():
	visible = true
	continue_hint.visible = false

func _on_dialogue_finished():
	_set_state(State.HIDDEN)
	_kill_tween()
	visible = false
	_clear_choices()
	_set_text_mode()

func _on_text_displayed(speaker: String, text: String):
	_set_text_mode()
	_clear_choices()
	speaker_label.text = speaker
	text_label.text = text
	text_label.custom_minimum_size.y = 60
	continue_hint.visible = false
	_start_typewriter(text)

func _on_choices_displayed(choices: Array):
	_kill_tween()
	_clear_choices()
	_set_choice_mode()
	
	speaker_label.text = I18n.t("select_response")
	text_label.text = ""
	text_label.custom_minimum_size.y = 0
	text_label.visible_ratio = 1.0
	continue_hint.visible = false
	
	for i in range(choices.size()):
		var choice: Dictionary = choices[i]
		var btn := Button.new()
		var is_locked := false
		var lock_reason := ""
		
		if choice.has("requires_skill"):
			var req_skill: String = choice["requires_skill"]
			var req_level: int = choice.get("requires_level", 1)
			var current_level: int = 0
			if SkillTree:
				current_level = SkillTree.get_skill_level(req_skill)
			if current_level < req_level:
				is_locked = true
				var skill_name: String = SkillTree.get_skill_name(req_skill) if SkillTree else req_skill
				lock_reason = " [%s]" % (I18n.t("requires_skill") % [skill_name, req_level])
		
		if is_locked:
			btn.text = "  %d. %s%s" % [i + 1, str(choice.get("text", "")), lock_reason]
			btn.disabled = true
			btn.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
			btn.add_theme_color_override("font_disabled_color", Color(0.4, 0.4, 0.4))
		else:
			btn.text = "  %d. %s" % [i + 1, str(choice.get("text", ""))]
			btn.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
			btn.add_theme_color_override("font_hover_color", Color(1, 0.95, 0.4))
			btn.add_theme_color_override("font_pressed_color", Color(1, 0.8, 0.2))
			var idx := i
			btn.pressed.connect(func(): _on_choice_selected(idx))
		
		btn.custom_minimum_size = Vector2(0, 28)
		btn.add_theme_font_size_override("font_size", 13)
		choices_container.add_child(btn)
	
	_set_state(State.SHOWING_CHOICES)
	await get_tree().process_frame
	if choices_container.get_child_count() > 0:
		var first := choices_container.get_child(0)
		if first is Button:
			first.grab_focus()

func _on_choice_selected(index: int):
	_clear_choices()
	DialogueManager.select_choice(index)

func _clear_choices():
	for child in choices_container.get_children():
		child.queue_free()

func _set_text_mode():
	panel.anchor_top = 1.0
	panel.offset_top = -150.0
	panel.anchor_bottom = 1.0
	panel.offset_bottom = 0.0

func _set_choice_mode():
	panel.anchor_top = 1.0
	panel.offset_top = -300.0
	panel.anchor_bottom = 1.0
	panel.offset_bottom = 0.0

func _start_typewriter(_text: String):
	_kill_tween()
	text_label.visible_ratio = 0.0
	_set_state(State.TYPING)
	_tween = create_tween()
	_tween.tween_property(text_label, "visible_ratio", 1.0, mini(_text.length() * 0.02, 1.5))
	_tween.tween_callback(func():
		if _state == State.TYPING:
			_set_state(State.WAITING_FOR_INPUT)
			continue_hint.visible = true
			continue_hint.text = I18n.t("space_continue")
	)

func _finish_typing():
	_kill_tween()
	text_label.visible_ratio = 1.0
	_set_state(State.WAITING_FOR_INPUT)
	continue_hint.visible = true
	continue_hint.text = I18n.t("space_continue")

func _set_state(new_state: State):
	_state = new_state

func _kill_tween():
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = null
