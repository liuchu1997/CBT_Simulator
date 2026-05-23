extends CharacterBody2D
class_name NPCBase

@export var npc_name: String = "NPC"
@export var npc_id: String = ""
@export var idle_dialogue: Array[String] = ["..."]

var facing: String = "down"
var is_interactable: bool = true

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interact_area: Area2D = $InteractArea

func _ready():
	if interact_area:
		interact_area.body_entered.connect(_on_body_entered)
		interact_area.body_exited.connect(_on_body_exited)
	sprite.play("idle_down")

func on_interact():
	if not is_interactable:
		return
	_face_player()
	_show_idle_dialogue()

func _face_player():
	var player := get_tree().get_first_node_in_group("player")
	if not player:
		return
	var diff: Vector2 = player.global_position - global_position
	if absf(diff.x) > absf(diff.y):
		facing = "right" if diff.x > 0 else "left"
	else:
		facing = "down" if diff.y > 0 else "up"
	sprite.play("idle_" + facing)

func _show_idle_dialogue():
	var dialogue: Array[Dictionary] = []
	for line in idle_dialogue:
		dialogue.append({"speaker": npc_name, "text": line})
	DialogueManager.start_dialogue(dialogue)

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		_show_interact_hint()

func _on_body_exited(body: Node2D):
	if body.is_in_group("player"):
		_hide_interact_hint()

func _show_interact_hint():
	var hud_nodes := get_tree().get_nodes_in_group("game_hud")
	if hud_nodes.is_empty():
		return
	var hint_label: Label = hud_nodes[0].get_node_or_null("InteractHint")
	if hint_label:
		hint_label.text = "[空格] 互动"
		hint_label.visible = true

func _hide_interact_hint():
	var hud_nodes := get_tree().get_nodes_in_group("game_hud")
	if hud_nodes.is_empty():
		return
	var hint_label: Label = hud_nodes[0].get_node_or_null("InteractHint")
	if hint_label:
		hint_label.visible = false
