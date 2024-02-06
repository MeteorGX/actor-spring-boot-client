extends Node

var _scenes = {}

# 切换关卡
func set_scene(path:String):
	print_debug("change scene: ",path)
	if _scenes.has(path):
		pass
	else:
		var instantiate:Node = load(path).instantiate()
		_scenes[path] = instantiate
		get_tree().root.add_child(instantiate)


