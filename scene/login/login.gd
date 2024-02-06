extends CanvasLayer


# 暴露在外的超时连接
@export var parent:Node
@export var websocket_timeout:float = 6
@export var enter_animation_name:String = "login_enter"
@export var mask_animation_name:String = "login_mask"
@export var change_scene_timeout:float = 3

var _pannel:Panel
var _address:LineEdit
var _uid:LineEdit
var _secret:LineEdit
var _login:Button
var _dialog:AcceptDialog
var _progress_box:Control
var _progress:ProgressBar
var _animation:AnimationPlayer
var _mask:ColorRect
var _scene:int


# 初始化
func _ready():
	# 界面元素
	_pannel = $Login/LoginPannel
	_address = _pannel.find_child("Address") as LineEdit
	_uid = _pannel.find_child("Uid") as LineEdit
	_secret = _pannel.find_child("Secret") as LineEdit 
	_login = _pannel.find_child("Login") as Button
	_dialog = $Login/Dialog
	_progress_box = $Login/ProgressBox
	_progress = $Login/ProgressBox/ProgressBar
	_animation = $Login/LoginAnimation
	_mask = $Login/Mask
	
	# 动画和绑定事件
	_mask.hide()
	_animation.play(enter_animation_name)
	bind_events()
	
	# 初始化值
	_scene = 0
	
	
# 绑定事件
func bind_events():
	WebSocketMgr.on_open.connect(on_open)
	WebSocketMgr.on_message.connect(on_message)

# 退出应用
func _exit_tree():
	WebSocketMgr.close()
	if WebSocketMgr.on_open.is_connected(on_open):
		WebSocketMgr.on_open.disconnect(on_open)
	if WebSocketMgr.on_message.is_connected(on_message):
		WebSocketMgr.on_message.disconnect(on_message)
	

# 开启事件
func on_open():
	print_debug("open")
	
	# 推送消息
	var uid = int(_uid.text)
	var secret = _secret.text
	var data = { "uid":uid, "secret":secret }
	WebSocketMgr.send_json(Protocols.create(Protocols.AUTH_LOGIN,data))
	
	# 进度移动到 50%
	_progress.value = 50


# 消息回调
func on_message(bytes:PackedByteArray):
	var json = bytes.get_string_from_utf8()
	print_debug("message:",json)
	
	# 解析数据
	var data:Variant = JSON.parse_string(json)
	var value = data["value"] as int
	var args:Variant = data["args"]
	
	# 拦截协议
	if value == Protocols.SYS_HEARTBEAT:
		pass # 心跳包, 跳过
	elif value == Protocols.AUTH_ERROR_BY_EXISTS or value == Protocols.AUTH_ERROR_BY_SECRET:
		# 异常登录, 切换错误
		_progress.value = 100
		login_error("Login")
		alert("Failed Params")
		WebSocketMgr.close()
	elif value == Protocols.AUTH_LOGIN_SUCCESS:
		# 登录成功进度移动到 80%, 准备切换的关卡
		_progress.value = 80
		change_scene(args["scene"] as int)


# 切换关卡
func change_scene(scene:int):
	# 确定关卡存在
	var scenes = JsonLoader.get_configs_by_scene();
	if scenes == null:
		login_error("Login")
		alert("Failed Scene")
		WebSocketMgr.close()
		return
	
	# 更新进度条获取准备切换的关卡
	for s in scenes:
		var scene_id:int = s["id"]
		var scene_path:String = s["resource"]
		if scene != 0 and scene_id == scene:
			# 切换动画和进度
			_login.text = "Login"
			_progress.value = 100
			_mask.show()
			_animation.play(mask_animation_name)
			
			# 等待切换关卡
			print_debug("active scene: ", s)
			var change_sec:float = _animation.current_animation_length
			await get_tree().create_timer(change_sec+change_scene_timeout).timeout
			
			# 切换关卡
			get_node(".").hide()
			parent.call_deferred("set_scene",scene_path)


# 错误提示
func alert(message:String,title:String = "Error"):
	_dialog.title = title
	_dialog.dialog_text = message
	_dialog.get_child(1, true).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER 
	_dialog.move_to_center()
	_dialog.show()
	

# 登录错误
func login_error(text:String = "Login"):
	_progress_box.hide()
	_progress.value = 0
	_login.disabled = false
	_login.text = text

# 触发点击
func _on_login_pressed():
	var address:String = _address.text
	if address.is_empty():
		alert("Address is Empty")
		return
	
	var uid:String = _address.text
	if uid.is_valid_int() or uid.is_empty():
		alert("Uid is Number")
		return 
	
	var secret:String = _secret.text
	if secret.is_empty():
		alert("Secret is Number")
		return 
	
	
	if WebSocketMgr.is_open():
		WebSocketMgr.close()
	
	var login_text = _login.text
	var state = WebSocketMgr.connect_to_url(address)
	print_debug("address:",address,state)
	if state != OK:
		alert("Connection is Error")
		return
	_login.text = "Logging..."
	_login.disabled = true
	
	# 显示进度条
	_progress_box.show()
	_progress.value = 10
	
	
	# 延迟判断进度大于30是登录成功返回玩家状态
	await get_tree().create_timer(websocket_timeout).timeout
	
	
	# 登录没有成功返回错误
	if WebSocketMgr.is_open() and _progress.value != 100:
		login_error(login_text)
		alert("Failed Login")
		WebSocketMgr.close()
		return
