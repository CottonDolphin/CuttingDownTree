# 管理游戏的物品数据
extends Node

#本轮收集木头的目标数量
var target_mount:int = 0

#物品列表
var item_list:Dictionary = {}

# 木头和金币的汇率
@export var exchange_rate:float = 1


# 更新木头的目标数量
func update_target_amount(amount:int) -> void:
	var collected_amount:int = get_item_num("wood")
	target_mount = amount
	UiUpdate.update_wood(collected_amount,target_mount)
	
# 更新木头的收集数量
func update_collected_amount(amount:int) -> void:
	add_item("wood",amount)
	var collected_amount:int = get_item_num("wood")
	UiUpdate.update_wood(collected_amount,target_mount)

# 添加数据
func add_item(item_name:String,add_amount:int) -> void:
	var current_amount:int = item_list.get(item_name,0)
	var new_amount:int = current_amount + add_amount
	item_list.set(item_name,new_amount)
	
# 获取数据
func get_item_num(item_name:String) -> int:
	return item_list.get(item_name,0)

# 将木头换成金币
func sell_wood_for_gold() -> void:
	var current_wood_num:int = item_list.get("wood")
	var income:float = current_wood_num * exchange_rate
	var current_gold:float = item_list.get("gold",0)
	current_gold += income
	item_list.set("gold",current_gold)
	item_list.set("wood",0)
	print("当前金币数量为",current_gold)

	
# 重置游戏数据
func reset_all_data():
	# 重置目标数量
	target_mount = 0
	
	item_list.clear()
	
