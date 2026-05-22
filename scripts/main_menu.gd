extends Control

@onready var start_btn: Button = $CenterContainer/VBoxContainer/StartBtn
@onready var reset_btn: Button = $CenterContainer/VBoxContainer/ResetBtn
@onready var level_label: Label = $CenterContainer/VBoxContainer/InfoContainer/TherapistLevelLabel
@onready var score_label: Label = $CenterContainer/VBoxContainer/InfoContainer/ScoreLabel

var _reset_pending: bool = false

func _ready():
	start_btn.pressed.connect(_on_start)
	reset_btn.pressed.connect(_on_reset)
	_update_info()

func _on_start():
	get_tree().change_scene_to_file("res://scenes/game_world.tscn")

func _on_reset():
	if _reset_pending:
		GameManager.reset_game()
		_update_info()
		_reset_pending = false
		reset_btn.text = "重新开始"
	else:
		_reset_pending = true
		reset_btn.text = "确认重置？"
		await get_tree().create_timer(3.0).timeout
		_reset_pending = false
		reset_btn.text = "重新开始"

func _update_info():
	level_label.text = "治疗师等级: Lv.%d" % GameManager.therapist_level
	score_label.text = "总积分: %d | 章节: %s" % [GameManager.total_score, GameManager.get_current_chapter_title()]
	if GameManager.total_sessions_count > 0:
		reset_btn.visible = true
	else:
		reset_btn.visible = false

func _input(event: InputEvent):
	if event.is_action_pressed("interact"):
		_on_start()
