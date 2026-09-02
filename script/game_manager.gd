# 管理游戏的物品数据
extends Node

#物品列表
var item_list:Dictionary = {}

# 添加数据
func add_item(item_name:String,add_num:int) -> void:
	var current_num:int = item_list.get(item_name,0)
	item_list.set(item_name,current_num + add_num)


# 获取数据
func get_item_num(item_name:String) -> int:
	return item_list.get(item_name,0)
