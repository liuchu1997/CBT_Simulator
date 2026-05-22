extends Node

func _ready():
	var font := load("res://fonts/NotoSansSC-Regular.otf") as FontFile
	if not font:
		print("[FontLoader] Failed to load font")
		return
	var theme := Theme.new()
	theme.default_font = font
	theme.default_font_size = 14
	_set_theme_recursive(get_tree().root, theme)
	print("[FontLoader] Chinese font applied successfully")

func _set_theme_recursive(node: Node, theme: Theme):
	if node is Control:
		node.theme = theme
	for child in node.get_children():
		_set_theme_recursive(child, theme)
