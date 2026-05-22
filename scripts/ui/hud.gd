extends Control

@onready var interact_label: Label = $InteractLabel

func _ready():
	visible = false

func show_hint():
	visible = true
	interact_label.text = "[ 空格 ] 对话"

func hide_hint():
	visible = false
