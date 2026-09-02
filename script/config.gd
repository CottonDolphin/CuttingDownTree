# config.gd
extends Node

@export var config_path: String = "res://config.json"

var _data: Dictionary = {}
var _loaded: bool = false

func _ready():
	load_config(config_path)

## 加载 JSON 配置文件
func load_config(path: String) -> bool:
	if not FileAccess.file_exists(path):
		push_error("配置文件不存在: " + path)
		return false
	
	var file = FileAccess.open(path, FileAccess.READ)
	var json = JSON.new()
	var err = json.parse(file.get_as_text())
	file.close()
	
	if err != OK:
		push_error("JSON 解析失败: " + json.get_error_message())
		return false
	
	_data = json.data
	_loaded = true
	print("配置加载成功，共 ", _data.size(), " 个分类")
	return true

## 获取完整配置
func get_data() -> Dictionary:
	return _data
	
# 获取对应类型的配置信息
func _get_config_by_type(type:String) -> Dictionary:
	var all_config:Dictionary = {}
	if self.is_loaded():
		all_config = Config.get_data()
	return all_config.get(type,{})

## 检查是否已加载
func is_loaded() -> bool:
	return _loaded
