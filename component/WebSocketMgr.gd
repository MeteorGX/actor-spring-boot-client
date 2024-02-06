extends Node

# 会话句柄
var _socket:WebSocketPeer = WebSocketPeer.new()

# 确认是否初始化开放过
var _opened:bool = false

# 监听信号事件
signal on_connect
signal on_open
signal on_closing
signal on_closed
signal on_message

# 初始化
func _ready():
	_opened = false
	set_process(false)


# 链接WebSocket服务
func connect_to_url(url:String,tls_client_options: TLSOptions = null):
	if tls_client_options == null:
		tls_client_options = TLSOptions.client_unsafe()
	var state:Error = _socket.connect_to_url(url,tls_client_options)
	if state == OK:
		_opened = false
		set_process(true)
	return state

# 确认是否连接
func is_open():
	var state = _socket.get_ready_state()
	return state == WebSocketPeer.STATE_OPEN or state == WebSocketPeer.STATE_CONNECTING


# 监听运行时
func _process(_delta):
	_socket.poll()
	var state = _socket.get_ready_state()
	
	# 状态分发
	if state == WebSocketPeer.STATE_CONNECTING:
		on_connect.emit()
	elif state == WebSocketPeer.STATE_OPEN:
		if not _opened:
			_opened = true
			on_open.emit()
		while _socket.get_available_packet_count():
			on_message.emit(_socket.get_packet())
	elif state == WebSocketPeer.STATE_CLOSING:
		on_closing.emit()
	elif state == WebSocketPeer.STATE_CLOSED:
		var code:int = _socket.get_close_code()
		var reason:String = _socket.get_close_reason()
		on_closed.emit(code,reason)
		set_process(false)

# 推送消息
func send_text(message:String):
	return _socket.send_text(message)

# 推送JSON数据
func send_json(data: Variant, indent: String = "", sort_keys: bool = true, full_precision: bool = false):
	return send_text(JSON.stringify(data,indent,sort_keys,full_precision))

# 关闭会话
func close(code: int = 1000, reason: String = ""):
	_socket.close(code,reason)
