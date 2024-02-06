# 请求响应数据协议: Protocols
extends Node
const AUTH_LOGIN:int = 100; # 客户端推送给服务端请求
const AUTH_ERROR_BY_EXISTS:int = 101; # 服务端授权不存在
const AUTH_ERROR_BY_SECRET:int = 102; # 服务端推送授权响应失败
const AUTH_ERROR_BY_OTHER:int = 103; # 服务端推送异地登录
const AUTH_LOGIN_SUCCESS:int = 110; # 登录成功
const SYS_HEARTBEAT:int = 1; # 心跳包推送


# 生成数据
func create(value:int,args: Variant):
	return { "value":value ,"args":args}
