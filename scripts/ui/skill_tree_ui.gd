extends Control

@onready var bg: ColorRect = $Background
@onready var main_panel: Panel = $MarginContainer/SkillPanel
@onready var points_label: Label = $MarginContainer/SkillPanel/VBox/Header/PointsLabel
@onready var close_btn: Button = $MarginContainer/SkillPanel/VBox/Header/CloseBtn
@onready var title_label: Label = $MarginContainer/SkillPanel/VBox/Header/TitleLabel
@onready var columns: HBoxContainer = $MarginContainer/SkillPanel/VBox/Columns

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("overlay_ui")
	visible = false
	close_btn.pressed.connect(_on_close)
	SkillTree.skill_upgraded.connect(_on_skill_upgraded)
	_update_static_texts()
	I18n.language_changed.connect(func(_l): _update_static_texts())

func _update_static_texts():
	title_label.text = I18n.t("skill_tree_title")
	close_btn.text = I18n.t("close")

func _input(event: InputEvent):
	if not event.is_action_pressed("skill_tree"):
		return
	if DialogueManager.is_active():
		return
	if _other_overlay_visible():
		return
	if visible:
		_close()
	else:
		_open()

func _other_overlay_visible() -> bool:
	var nodes := get_tree().get_nodes_in_group("overlay_ui")
	for n in nodes:
		if n != self and n is Control and n.visible:
			return true
	return false

func _open():
	visible = true
	get_tree().paused = true
	_refresh()

func _close():
	visible = false
	get_tree().paused = false

func _on_close():
	_close()

func _refresh():
	points_label.text = "%s: %d" % [I18n.t("skill_points_label"), GameManager.skill_points]
	_clear_columns()
	
	for line in SkillTree.get_all_lines():
		var col := VBoxContainer.new()
		col.add_theme_constant_override("separation", 4)
		
		var title := Label.new()
		title.text = SkillTree.get_skill_name(line)
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title.add_theme_font_size_override("font_size", 16)
		title.add_theme_color_override("font_color", Color(1, 0.9, 0.4))
		col.add_child(title)
		
		var level: int = SkillTree.get_skill_level(line)
		for i in range(4):
			var btn := Button.new()
			var lvl_name: String = SkillTree.get_level_name(line, i + 1)
			if i < level:
				btn.text = "Lv%d: %s ✓" % [i + 1, lvl_name]
				btn.disabled = true
				btn.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4))
			elif i == level:
				btn.text = "Lv%d: %s [%s]" % [i + 1, lvl_name, I18n.t("skill_upgrade")]
				btn.disabled = GameManager.skill_points <= 0
				btn.add_theme_color_override("font_color", Color(1, 1, 0.5))
				var l := line
				btn.pressed.connect(func(): _on_upgrade(l))
			else:
				btn.text = "Lv%d: ???" % [i + 1]
				btn.disabled = true
				btn.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
			btn.custom_minimum_size = Vector2(140, 30)
			btn.add_theme_font_size_override("font_size", 12)
			col.add_child(btn)
		
		var status := Label.new()
		status.text = "%s: %d/4" % [I18n.t("skill_maxed"), level]
		status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		status.add_theme_font_size_override("font_size", 11)
		status.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		col.add_child(status)
		
		columns.add_child(col)
	
	close_btn.grab_focus()

func _clear_columns():
	for child in columns.get_children():
		child.queue_free()

func _on_upgrade(line: String):
	SkillTree.upgrade_skill(line)
	_refresh()

func _on_skill_upgraded(_line: String, _level: int):
	if visible:
		_refresh()
