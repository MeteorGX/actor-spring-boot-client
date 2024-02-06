extends Node

const tables = [ "Scene.json" ]

var _configs = {}

# 加载策划配置表
func _ready():
	# 加载表
	for table:String in tables:
		var file:String = "res://table/%s" % table
		var f: FileAccess = FileAccess.open(file,FileAccess.READ)
		if f != null:
			var data = JSON.parse_string(f.get_as_text())
			if data != null:
				table = table.replace(".json","").to_lower()
				print_debug("table: ",table)
				_configs[table] = data



# 判断配置存在
func has_config(key:String):
	return _configs.has(key)

# 获取配置
func get_config(key:String,default_value:Variant = null):
	return _configs.get(key,default_value)
	
# 获取全部配置
func get_configs():
	return _configs


# 获取场景配置
func get_configs_by_scene():
	var config = _configs.get("scene")
	if config == null:
		return {}
	else:
		return config
