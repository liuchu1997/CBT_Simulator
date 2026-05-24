extends Node2D

@export var room_id: String = "lobby"
@export var room_name: String = ""
@export var bg_color: Color = Color(0.15, 0.15, 0.2)

func _ready():
	var label: Label = get_node_or_null("RoomLabel")
	var desc: RichTextLabel = get_node_or_null("Description")
	_update_room_texts(label, desc)
	I18n.language_changed.connect(func(_l): _update_room_texts(label, desc))

func _update_room_texts(label: Label, desc: RichTextLabel):
	var label_key := room_id + "_label"
	var desc_key := room_id + "_desc"
	if label:
		label.text = I18n.t(label_key)
	if desc:
		desc.text = I18n.t(desc_key)
