# 管理游戏的物品数据和变量
extends Node

#本轮收集木头的目标数量
var target_mount:int = 0

#物品列表
var item_list:Dictionary = {}

# 木头和金币的汇率
@export var exchange_rate:float = 1

# 游戏是否暂停
var is_paused:bool = false



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

# 减少物品数量
func reduce_item_num(item_name:String,amount:int) -> void:
	var current_amount:int = item_list.get(item_name,0)
	var new_amount:int = current_amount - amount
	if new_amount >= 0:
		item_list.set(item_name,new_amount)
	else:
		push_error("物品数量不能为负数")

# 花钱
func spend_gold(amount:int) -> void:
	var what_kind_of_money:String = "gold"
	reduce_item_num(what_kind_of_money,amount)
	UiUpdate.update_gold(get_item_num(what_kind_of_money))

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
func reset_all_data() -> void:
	# 重置目标数量
	target_mount = 0
	
	item_list.clear()
	
# 暂停
func pause() -> void:
	is_paused = true

# 恢复游戏
func resume() -> void:
	is_paused = false
