extends Node

# 消息事件信号, 事件有以下状态
# 初始化, 连接完成, 消息传递, 关闭 
signal on_init
signal on_connected
signal on_message
signal on_close

# 会话句柄
var _ws:WebSocketPeer = WebSocketPeer.new()
var _connected:bool = false


# 启动初始化
func _ready():
	set_physics_process(false)
	_connected = false


# 启动消息监听
func _physics_process(_delta):
	# 获取事件并提取状态
	_ws.poll()
	var state = _ws.get_ready_state()
	
	# 判断状态
	if state == WebSocketPeer.STATE_OPEN:
		# 已经首次连接
		if not _connected:
			on_connected.emit()
			_connected = true
		
		# 有消息唤醒服务, 转发给外部函数
		while _ws.get_available_packet_count():
			on_message.emit(_ws.get_packet())
	elif state == WebSocketPeer.STATE_CLOSING:
		# 正在关闭不需要处理
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		# 获取关闭状态和原因并唤醒事件
		var code = _ws.get_close_code()
		var reason = _ws.get_close_reason()
		on_close.emit(code,reason)
		
		# 停止处理。
		_connected = false
		set_physics_process(false) 
	

# 链接H5请求
func connect_ws(url:String,options: TLSOptions = null):
	var result:Error
	if options == null:
		result = _ws.connect_to_url(url,TLSOptions.client_unsafe())
	else:
		result = _ws.connect_to_url(url,options)
	
	# 如果连接完成直接开始调用逻辑帧
	if result == OK:
		set_physics_process(true)
	
	# 初始化推送, 结果传递内部让其按照逻辑判断
	on_init.emit(result) 
	return result

# 关闭连接
func close_ws(code: int = 1000, reason: String = ""):
	_ws.close(code,reason)
	
# 获取状态
func state_ws():
	return _ws.get_ready_state()

# 确认目前已经打开
func is_state_open():
	return state_ws() == WebSocketPeer.STATE_OPEN
	
# 确认已创建套接字, 连接尚未打开
func is_state_connecting():
	return state_ws() == WebSocketPeer.STATE_CONNECTING

# 连接正在关闭过程中
func is_state_closing():
	return state_ws() == WebSocketPeer.STATE_CLOSING

# 连接已经关闭
func is_state_closed():
	return state_ws() == WebSocketPeer.STATE_CLOSED


# 推送文本消息
func send_text(text:String):
	return _ws.send_text(text)

# 推送JSON消息
func send_json(data: Variant, indent: String = "", sort_keys: bool = true, full_precision: bool = false):
	return send_text(JSON.stringify(data,indent,sort_keys,full_precision))


# 绑定初始化事件
func bind_init(cb:Callable,flags: int = 0):
	return on_init.connect(cb,flags)

# 解绑初始化事件
func unbind_init(cb:Callable):
	if on_init.is_connected(cb):
		on_init.disconnect(cb)

# 完成连接的绑定事件
func bind_connected(cb:Callable,flags: int = 0):
	return on_connected.connect(cb,flags)

# 解绑连接事件
func unbind_connected(cb:Callable):
	if on_init.is_connected(cb):
		on_connected.disconnect(cb)

# 绑定消息获取事件
func bind_message(cb:Callable,flags: int = 0):
	return on_message.connect(cb,flags)
	
# 解绑消息获取事件
func unbind_message(cb:Callable):
	if on_message.is_connected(cb):
		on_message.disconnect(cb)
	
# 绑定关闭事件
func bind_close(cb:Callable,flags: int = 0):
	return on_close.connect(cb,flags)
	
# 解绑关闭事件
func unbind_close(cb:Callable,flags: int = 0):
	if on_close.is_connected(cb):
		on_close.disconnect(cb)
