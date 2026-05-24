extends Node

signal room_changed(room_id: String)

var _current_room: String = "lobby"
var _room_configs: Dictionary = {
	"lobby": {
		"name_key": "room_lobby",
		"bg_color": Color(0.15, 0.15, 0.2),
		"floor_tile": Vector2i(0, 0),
		"wall_tile": Vector2i(0, 1),
	},
	"room_anxiety": {
		"name_key": "room_anxiety",
		"bg_color": Color(0.2, 0.15, 0.12),
		"floor_tile": Vector2i(4, 0),
		"wall_tile": Vector2i(2, 1),
		"patient_id": "zhang_hao",
	},
	"room_depression": {
		"name_key": "room_depression",
		"bg_color": Color(0.12, 0.12, 0.2),
		"floor_tile": Vector2i(3, 0),
		"wall_tile": Vector2i(2, 1),
		"patient_id": "lin_xiaoyu",
	},
	"room_personality": {
		"name_key": "room_personality",
		"bg_color": Color(0.18, 0.12, 0.18),
		"floor_tile": Vector2i(4, 0),
		"wall_tile": Vector2i(0, 1),
		"patient_id": "wang_mei",
	},
	"room_crisis": {
		"name_key": "room_crisis",
		"bg_color": Color(0.2, 0.1, 0.1),
		"floor_tile": Vector2i(3, 0),
		"wall_tile": Vector2i(0, 1),
		"patient_id": "final_review",
	},
}

var _chapter_to_room: Dictionary = {
	"chapter_1": "room_depression",
	"chapter_2": "room_anxiety",
	"chapter_3": "room_personality",
	"chapter_final": "room_crisis",
}

func get_current_room() -> String:
	return _current_room

func get_room_config(room_id: String) -> Dictionary:
	return _room_configs.get(room_id, _room_configs["lobby"])

func get_room_for_chapter(chapter_id: String) -> String:
	return _chapter_to_room.get(chapter_id, "lobby")

func get_room_for_patient(patient_id: String) -> String:
	for room_id in _room_configs:
		var config: Dictionary = _room_configs[room_id]
		if config.get("patient_id", "") == patient_id:
			return room_id
	return "lobby"

func change_room(room_id: String):
	if not _room_configs.has(room_id):
		return
	_current_room = room_id
	room_changed.emit(room_id)

func change_to_patient_room(patient_id: String):
	var room := get_room_for_patient(patient_id)
	change_room(room)

func change_to_chapter_room(chapter_id: String):
	var room := get_room_for_chapter(chapter_id)
	change_room(room)

func return_to_lobby():
	change_room("lobby")

func get_room_name(room_id: String) -> String:
	var key: String = _room_configs.get(room_id, {}).get("name_key", "state_unknown")
	if I18n:
		return I18n.t(key)
	return room_id
