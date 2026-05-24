extends Node2D

const FLOOR := Vector2i(0, 0)
const FLOOR_CARPET := Vector2i(3, 0)
const FLOOR_BLUE := Vector2i(4, 0)
const WALL := Vector2i(0, 1)
const WALL_BORDER := Vector2i(1, 1)
const WALL_WHITE := Vector2i(2, 1)
const DOOR := Vector2i(0, 2)
const DOOR_BODY := Vector2i(1, 2)
const DESK := Vector2i(1, 3)
const CHAIR := Vector2i(3, 3)
const BOOKSHELF := Vector2i(6, 3)
const PLANT := Vector2i(7, 3)
const WINDOW := Vector2i(0, 4)

const MW := 40
const MH := 30

@onready var floor_map: TileMap = $FloorMap
@onready var wall_map: TileMap = $WallMap
@onready var player: CharacterBody2D = $Player
@onready var status_text: Label = $HUD/StatusBar/StatusText
@onready var task_hint: RichTextLabel = $HUD/TaskHint
@onready var hud_hint: Label = $HUD/InteractHint
@onready var hotkey_text: Label = $HUD/HotkeyBar/HotkeyText
@onready var emotion_anger: Node2D = $EmotionAnger
@onready var emotion_sadness: Node2D = $EmotionSadness
@onready var emotion_fear: Node2D = $EmotionFear
@onready var emotion_joy: Node2D = $EmotionJoy

var _first_interact_done := false
var _chapter_fail_reason := ""

func _ready():
	$HUD.add_to_group("game_hud")
	var ts := _build_tileset()
	floor_map.tile_set = ts
	wall_map.tile_set = ts
	_paint_floor()
	_paint_walls()
	_reposition_characters()
	_setup_task_system()
	_update_task()
	_update_hotkey_bar()
	_setup_camera()
	I18n.language_changed.connect(func(_l): _update_task(); _update_hotkey_bar(); hud_hint.text = I18n.t("space_talk"))

func _setup_camera():
	var cam: Camera2D = player.get_node_or_null("Camera2D")
	if cam:
		cam.limit_left = 0
		cam.limit_top = 0
		cam.limit_right = MW * 16
		cam.limit_bottom = MH * 16
		cam.zoom = Vector2(2.0, 2.0)

func _setup_task_system():
	GameManager.session_ended.connect(_on_session_ended)
	GameManager.patient_unlocked.connect(_on_patient_unlocked)
	GameManager.chapter_completed.connect(_on_chapter_completed)
	GameManager.chapter_failed.connect(_on_chapter_failed)
	GameManager.score_updated.connect(_on_score_updated)
	if RoomManager:
		RoomManager.room_changed.connect(_on_room_changed)

func _on_room_changed(room_id: String):
	if RoomManager:
		var config: Dictionary = RoomManager.get_room_config(room_id)
		var bg_color: Color = config.get("bg_color", Color(0.15, 0.15, 0.2))
		var bg_node := get_node_or_null("Background")
		if bg_node and bg_node is ColorRect:
			bg_node.color = bg_color
	_update_task()

func _on_session_ended(_pid: String, _snum: int):
	_first_interact_done = true
	_update_task()

func _on_patient_unlocked(_pid: String):
	_update_task()

func _on_chapter_completed(_chapter_id: String):
	_chapter_fail_reason = ""
	_update_task()

func _on_chapter_failed(_chapter_id: String, reason: String):
	_chapter_fail_reason = reason
	_update_task()

func _on_score_updated(_pid: String):
	_update_task()

func _update_task():
	var level := GameManager.therapist_level
	var score := GameManager.total_score
	var chapter_title: String = GameManager.get_current_chapter_title()
	status_text.text = "Lv.%d | %s | %s: %d | %s: %d" % [level, chapter_title, I18n.t("total_score"), score, I18n.t("skill_points"), GameManager.skill_points]
	hud_hint.text = I18n.t("space_talk")
	if RoomManager and RoomManager.get_current_room() != "lobby":
		status_text.text += " | [%s]" % RoomManager.get_room_name(RoomManager.get_current_room())
	
	var hint := ""
	if not _first_interact_done:
		hint = "[color=yellow]%s[/color]  |  [color=gray]%s[/color]" % [I18n.t("hint_interact"), I18n.t("hint_task")]
	elif _chapter_fail_reason != "":
		hint = "[color=red]%s[/color] | [color=yellow]%s[/color]  |  [color=gray]%s[/color]" % [I18n.t("hint_not_passed"), I18n.t("hint_retry"), I18n.t("hint_skills")]
	else:
		var cur_def: Dictionary = GameManager.get_chapter_def(GameManager.current_chapter)
		var pid: String = cur_def.get("patient_id", "")
		if pid != "" and pid != "final_review":
			var progress: int = GameManager.get_patient_progress(pid)
			var needed: int = cur_def.get("required_sessions", 3)
			var pname: String = GameManager.PATIENT_NAMES.get(pid, pid)
			if progress < needed:
				hint = "[color=cyan]%s[/color] %s %d/%d  |  [color=gray]%s[/color]" % [pname, I18n.t("hint_treatment_progress"), progress, needed, I18n.t("hint_skills")]
			else:
				hint = "[color=green]%s %s[/color]  |  [color=gray]%s[/color]" % [pname, I18n.t("task_completed"), I18n.t("hint_task")]
		else:
			hint = "[color=gray]T %s | K %s | J %s[/color]" % [I18n.t("task_current"), I18n.t("skill_tree_title"), I18n.t("journal_title")]
	
	task_hint.text = hint

func _update_hotkey_bar():
	hotkey_text.text = I18n.t("hotkey_bar")

func _build_tileset() -> TileSet:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(16, 16)
	
	var source := TileSetAtlasSource.new()
	source.texture = load("res://assets/sprites/tilesets/indoor.png")
	source.texture_region_size = Vector2i(16, 16)
	source.separation = Vector2i(0, 0)
	source.margins = Vector2i(0, 0)
	
	ts.add_source(source, 0)
	ts.add_physics_layer()
	ts.set_physics_layer_collision_layer(0, 4)
	
	var all_used := {
		FLOOR: true, FLOOR_CARPET: true, FLOOR_BLUE: true,
		WALL: true, WALL_BORDER: true, WALL_WHITE: true,
		DOOR: true, DOOR_BODY: true,
		DESK: true, CHAIR: true, BOOKSHELF: true, PLANT: true, WINDOW: true,
	}
	for coords in all_used:
		source.create_tile(coords)
	
	var solid_tiles := [WALL, WALL_BORDER, WALL_WHITE, DESK, BOOKSHELF]
	for coords in solid_tiles:
		var data: TileData = source.get_tile_data(coords, 0)
		if data:
			data.add_collision_polygon(0)
			data.set_collision_polygon_points(0, 0, PackedVector2Array([
				Vector2(0, 0), Vector2(16, 0), Vector2(16, 16), Vector2(0, 16)
			]))
	
	return ts

func _paint_floor():
	for x in range(MW):
		for y in range(MH):
			if x == 0 or x == MW - 1 or y == 0 or y == MH - 1:
				continue
			if x >= 1 and x <= 18 and y >= 1 and y <= 13:
				floor_map.set_cell(0, Vector2i(x, y), 0, FLOOR_CARPET)
			elif x >= 21 and x <= MW - 2 and y >= 1 and y <= 13:
				floor_map.set_cell(0, Vector2i(x, y), 0, FLOOR_BLUE)
			else:
				floor_map.set_cell(0, Vector2i(x, y), 0, FLOOR)

func _paint_walls():
	for x in range(MW):
		wall_map.set_cell(0, Vector2i(x, 0), 0, WALL_BORDER)
		wall_map.set_cell(0, Vector2i(x, MH - 1), 0, WALL_BORDER)
	for y in range(MH):
		wall_map.set_cell(0, Vector2i(0, y), 0, WALL)
		wall_map.set_cell(0, Vector2i(MW - 1, y), 0, WALL)
	
	for y in range(1, 14):
		wall_map.set_cell(0, Vector2i(19, y), 0, WALL)
		wall_map.set_cell(0, Vector2i(20, y), 0, WALL)
	for y in range(7, 9):
		wall_map.set_cell(0, Vector2i(19, y), -1)
		wall_map.set_cell(0, Vector2i(20, y), -1)
	
	for x in range(1, MW - 1):
		wall_map.set_cell(0, Vector2i(x, 14), 0, WALL)
	for x in range(8, 12):
		wall_map.set_cell(0, Vector2i(x, 14), -1)
	for x in range(28, 32):
		wall_map.set_cell(0, Vector2i(x, 14), -1)
	
	for x in range(15, 25):
		wall_map.set_cell(0, Vector2i(x, MH - 1), -1)
	
	_furniture_room_a()
	_furniture_room_b()
	_furniture_lobby()
	_windows()
	_decorations()

func _furniture_room_a():
	wall_map.set_cell(0, Vector2i(3, 3), 0, DESK)
	wall_map.set_cell(0, Vector2i(4, 3), 0, DESK)
	wall_map.set_cell(0, Vector2i(3, 4), 0, CHAIR)
	wall_map.set_cell(0, Vector2i(16, 1), 0, BOOKSHELF)
	wall_map.set_cell(0, Vector2i(17, 1), 0, BOOKSHELF)

func _furniture_room_b():
	wall_map.set_cell(0, Vector2i(24, 3), 0, DESK)
	wall_map.set_cell(0, Vector2i(25, 3), 0, DESK)
	wall_map.set_cell(0, Vector2i(24, 4), 0, CHAIR)
	wall_map.set_cell(0, Vector2i(35, 1), 0, BOOKSHELF)
	wall_map.set_cell(0, Vector2i(36, 1), 0, BOOKSHELF)

func _furniture_lobby():
	wall_map.set_cell(0, Vector2i(5, 19), 0, DESK)
	wall_map.set_cell(0, Vector2i(6, 19), 0, DESK)
	wall_map.set_cell(0, Vector2i(33, 19), 0, DESK)
	wall_map.set_cell(0, Vector2i(34, 19), 0, DESK)
	
	# Place emotion NPCs in lobby
	$EmotionAnger.position = Vector2(8 * 16, 20 * 16)
	$EmotionSadness.position = Vector2(14 * 16, 20 * 16)
	$EmotionFear.position = Vector2(26 * 16, 20 * 16)
	$EmotionJoy.position = Vector2(32 * 16, 20 * 16)

func _windows():
	for x in [4, 5, 12, 13, 26, 27, 34, 35]:
		wall_map.set_cell(0, Vector2i(x, 0), 0, WINDOW)

func _decorations():
	for pos in [Vector2i(2, 2), Vector2i(37, 2), Vector2i(2, 27), Vector2i(37, 27)]:
		wall_map.set_cell(0, pos, 0, PLANT)

func _reposition_characters():
	$Player.position = Vector2(20 * 16, 22 * 16)
	$LinXiaoyu.position = Vector2(10 * 16, 8 * 16)
	$ZhangHao.position = Vector2(30 * 16, 8 * 16)
	$WangMei.position = Vector2(10 * 16, 18 * 16)
	$Receptionist.position = Vector2(20 * 16, 24 * 16)
