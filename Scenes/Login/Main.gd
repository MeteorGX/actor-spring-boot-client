extends Node

# 绑定所有相关输入框
var _address:LineEdit
var _uid:LineEdit
var _secret:LineEdit

# 初始化绑定所有事件元素
func _ready():
	# 绑定节点
	_address = $Layers/Address
	_uid = $Layers/Uid
	_secret = $Layers/Secret
	
# 进入节点
func _enter_tree():
	# 绑定数据推送事件
	NetMgr.bind_init(_on_init)
	NetMgr.bind_connected(_on_connected)
	NetMgr.bind_message(_on_message)
	NetMgr.bind_close(_on_close)

# 切换场景时候解绑所有监听
func _exit_tree():
	NetMgr.unbind_init(_on_init)
	NetMgr.unbind_connected(_on_connected)
	NetMgr.unbind_message(_on_message)
	NetMgr.unbind_close(_on_close)
	

# 初始化完成事件
func _on_init(_result):
	print("open")


# 连接完成之后推送事件
func _on_connected():
	print("connected")
	var uid = int(_uid.text)
	var secret = _secret.text

	# 连接完成推送登录数据
	var data = Protocols.make(Protocols.LOGIN,{ "uid":uid,"secret":secret })
	if NetMgr.send_text(data) != OK:
		NetMgr.close_ws()
		return 

# 关闭事件
func _on_close(code,reason):
	print("WebSocket 已关闭，代码：%d，原因 %s。干净得体：%s" % [code, reason, code != -1])
	Toasts.alert($".","close websocket server",2.3)

# 服务端响应事件
func _on_message(bytes:PackedByteArray):
	var json_string = bytes.get_string_from_utf8()
	if json_string.length() <= 0:
		Toasts.alert($".","failed by response json",2.3)
		return
	
	# 转化 JSON 识别出格式
	var json:Variant = JSON.parse_string(json_string)
	var value:int = json["value"]
	var args:Dictionary = json["args"]
	
	# 这里只需要监听跳转的场景或者登录错误
	if value == Protocols.SECRET_ERROR:
		Toasts.alert($".","Failed by secret",2.3)
		return
	elif value == Protocols.CHANGE_SCENE:
		SceneMgr.change(int(args.get("scene")))
		return
	

# 登录触发
func _on_login_trigger():
	var address = _address.text
	if address.length() <= 0:
		Toasts.alert($".","Failed by webSocket address",2.3)
		return
		
	var uid = int(_uid.text)
	var secret = _secret.text
	if uid <= 0 or secret.length() <= 0:
		Toasts.alert($".","Failed by uid or secret",2.3)
		return 
		

	# 确定如果没有关闭就关闭之后再连接
	if not NetMgr.is_state_closed():
		NetMgr.close_ws()
	
	# 确认连接
	if NetMgr.connect_ws(address) != OK:
		Toasts.alert($".","Failed by connect url",2.3)
		return 

	# 等待切换场景, 这里一般都是进度条百分比等待
	Toasts.alert($".","waiting for server to switch scenarios......",60)
