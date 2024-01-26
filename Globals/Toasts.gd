extends Node
# 全局提示模态功能

var _alert_box:Resource

func _ready():
	_alert_box = preload("res://Globals/ToastsBox/Alert.tscn")

	pass # Replace with function body.

# 简单警告提示
func alert(parent:Node,text:String,hide_sec:float = 10.0):
	# 添加节点
	var node:Node = _alert_box.instantiate()
	node.name = "Toasts_Alert_%f" % Time.get_unix_time_from_system()
	var text_node:LineEdit = node.find_child("AlertText") as LineEdit
	text_node.text = text
	parent.add_child(node)
	
	# 超时删除节点
	await get_tree().create_timer(hide_sec).timeout
	if node != null:
		parent.remove_child(node)

