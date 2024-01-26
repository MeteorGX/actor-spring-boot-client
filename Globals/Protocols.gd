# 全局静态协议码
extends Node

const LOGIN:int = 100 # 请求登录: 客户端 -> 服务端
 
const SECRET_ERROR:int = 101 # 授权错误: 服务端 -> 客户端

const HEARTBEAT:int = 103 # 心跳包: 服务端 -> 客户端

const OTHER_LOGIN:int = 105 # 异地登录: 服务端 -> 客户端

const CHANGE_SCENE:int = 121 # 切换关卡: 服务端 -> 客户端


# 生成协议文本
func make(value:int,args:Variant):
	var data = { "value": value, "args": args}
	return JSON.stringify(data)
