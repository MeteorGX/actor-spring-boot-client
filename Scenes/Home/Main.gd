extends Node


# 进入节点
func _enter_tree():
	# 已经切换场景, 绑定需要监听的协议事件
	NetMgr.bind_message(_on_message)
	NetMgr.bind_close(_on_close)
	
# 退出节点
func _exit_tree():
	NetMgr.bind_message(_on_message)
	NetMgr.bind_close(_on_close)
	
	
# 数据响应
func _on_message(bytes:PackedByteArray):
	var json_string = bytes.get_string_from_utf8()
	print(json_string)
	pass
	
# 关闭事件
func _on_close(code,reason):
	print("WebSocket 已关闭，代码：%d，原因 %s。干净得体：%s" % [code, reason, code != -1])
	
	# 返回登录页面
	SceneMgr.change(0)
