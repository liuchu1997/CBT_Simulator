extends Control

@onready var interact_label: Label = $InteractLabel

func _ready():
	visible = false

func show_hint():
	visible = true
	interact_label.text = I18n.t("space_talk")

func hide_hint():
	visible = false
