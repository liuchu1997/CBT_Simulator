extends Control

@onready var start_btn: Button = $CenterContainer/VBoxContainer/StartBtn
@onready var reset_btn: Button = $CenterContainer/VBoxContainer/ResetBtn
@onready var level_label: Label = $CenterContainer/VBoxContainer/InfoContainer/TherapistLevelLabel
@onready var score_label: Label = $CenterContainer/VBoxContainer/InfoContainer/ScoreLabel
@onready var lang_btn: Button = $CenterContainer/VBoxContainer/LangBtn

var _reset_pending: bool = false

func _ready():
	start_btn.pressed.connect(_on_start)
	reset_btn.pressed.connect(_on_reset)
	if lang_btn:
		lang_btn.pressed.connect(_on_lang_switch)
	_update_info()
	_apply_language()
	if I18n:
		I18n.language_changed.connect(func(_l): _apply_language())

func _on_start():
	get_tree().change_scene_to_file("res://scenes/game_world.tscn")

func _on_reset():
	if _reset_pending:
		GameManager.reset_game()
		_update_info()
		_reset_pending = false
		reset_btn.text = I18n.t("reset_game")
	else:
		_reset_pending = true
		reset_btn.text = I18n.t("confirm_reset")
		await get_tree().create_timer(3.0).timeout
		_reset_pending = false
		reset_btn.text = I18n.t("reset_game")

func _on_lang_switch():
	if I18n:
		I18n.set_language("en" if I18n.current_lang == "zh" else "zh")

func _apply_language():
	$CenterContainer/VBoxContainer/TitleLabel.text = I18n.t("game_title")
	start_btn.text = I18n.t("start_game")
	reset_btn.text = I18n.t("reset_game")
	if lang_btn:
		lang_btn.text = I18n.t("lang_switch")
	_update_info()

func _update_info():
	level_label.text = "%s: Lv.%d" % [I18n.t("therapist_level"), GameManager.therapist_level]
	score_label.text = "%s: %d | %s: %s" % [I18n.t("total_score"), GameManager.total_score, I18n.t("chapter_label"), GameManager.get_current_chapter_title()]
	if GameManager.total_sessions_count > 0:
		reset_btn.visible = true
	else:
		reset_btn.visible = false

func _input(event: InputEvent):
	if event.is_action_pressed("interact"):
		_on_start()
