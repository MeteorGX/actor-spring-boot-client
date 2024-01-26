extends Node
# 场景加载器

# 会话
var _scenes = {}

# 初始化
func _ready():
	# 实际上这里应该采用策划配表读取加载, 这里先手动处理
	
	# 先加载 0 = 登录关卡, 1 = 用户首页
	_scenes[0] = preload("res://Scenes/Login/Main.tscn")
	_scenes[1] = preload("res://Scenes/Home/Main.tscn")
	pass

func change(scene:int):
	if _scenes.has(scene):
		get_tree().change_scene_to_packed(_scenes.get(scene))
 
