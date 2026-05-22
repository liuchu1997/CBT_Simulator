extends Control

@onready var pause_panel: Panel = $CenterContainer/PausePanel
@onready var resume_btn: Button = $CenterContainer/PausePanel/MarginContainer/VBoxContainer/ResumeBtn
@onready var main_menu_btn: Button = $CenterContainer/PausePanel/MarginContainer/VBoxContainer/MainMenuBtn
@onready var save_btn: Button = $CenterContainer/PausePanel/MarginContainer/VBoxContainer/SaveBtn
@onready var reset_btn: Button = $CenterContainer/PausePanel/MarginContainer/VBoxContainer/ResetBtn
@onready var reset_confirm: Label = $CenterContainer/PausePanel/MarginContainer/VBoxContainer/ResetConfirm

var _reset_pending: bool = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	resume_btn.pressed.connect(_on_resume)
	main_menu_btn.pressed.connect(_on_main_menu)
	save_btn.pressed.connect(_on_save)
	reset_btn.pressed.connect(_on_reset)

func _input(event: InputEvent):
	if not event.is_action_pressed("pause"):
		return
	if get_tree().paused:
		_on_resume()
	elif not DialogueManager.is_active():
		_pause()

func _pause():
	_reset_pending = false
	reset_confirm.visible = false
	get_tree().paused = true
	visible = true
	resume_btn.grab_focus()

func _on_resume():
	get_tree().paused = false
	visible = false

func _on_main_menu():
	GameManager.save_game()
	get_tree().paused = false
	visible = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_save():
	GameManager.save_game()
	save_btn.text = "已保存!"
	await get_tree().create_timer(1.0).timeout
	save_btn.text = "保存游戏"

func _on_reset():
	if _reset_pending:
		GameManager.reset_game()
		get_tree().paused = false
		visible = false
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	else:
		_reset_pending = true
		reset_confirm.visible = true
		await get_tree().create_timer(3.0).timeout
		_reset_pending = false
		reset_confirm.visible = false
