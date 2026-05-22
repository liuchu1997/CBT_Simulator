extends SceneTree

func _initialize():
	var test_node := Node.new()
	test_node.name = "TestRunner"
	test_node.set_script(load("res://tests/test_all.gd"))
	root.add_child(test_node)
