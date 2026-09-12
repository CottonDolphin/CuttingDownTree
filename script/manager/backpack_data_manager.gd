class_name BackpackDataManager
extends RefCounted


@export_category("玩家背包")
@export var backpack:Dictionary[String,Array] = {}

var backpack_grids:Array = []

# 空白格子序号
var empty_grid_index:int = 0

# 背包上限
@export var backpack_limit:int = 8

# 物品存储上限
var stack_limit:int = 1

# 单格资源上限
@export var single_grid_limit:int = 99

# 填充新格子的信号
signal fill_new_slot(slot_index: int, item_data: Dictionary,increase_num:int)

# 更新数字的信号
signal update_number(slot_index: int,current_num:int)

# 添加到新格子中
func add_to_new_grid(index_array:Array,item_data:Dictionary,item_num:int) -> void:
	while item_num > 0:
		if empty_grid_index > -1 and empty_grid_index < backpack_limit:
			#当添加数量小于单个格子数量限制时，直接添加
			var increase_num:int = 0
			if item_num <= stack_limit:
				backpack_grids[empty_grid_index] += item_num
				increase_num = item_num
				item_num = 0
			else:
				#将单个格子填满，然后继续找下个格子
				item_num -= stack_limit
				backpack_grids[empty_grid_index] += stack_limit
				increase_num = stack_limit
				
			
			index_array.append(empty_grid_index)
			
			fill_new_slot.emit(empty_grid_index,item_data,increase_num)
			
			
			empty_grid_index = get_empty_grid_index()				
		else:
			print("背包已满")

# 获取空格序号
func get_empty_grid_index() -> int:
	var index = -1
	for i in range(backpack_grids.size()):
		if backpack_grids[i] == 0:
			index = i
			break
	return index

# 获得物品
func add_items(item_data:Dictionary,item_num:int) -> void:
	print("empty_grid_index:",empty_grid_index)
	var item_name:String = item_data.name
	var current_item_indexs:Array = backpack.get(item_name,[])
	
	# 如果背包中没有该资源，尝试添加到新的格子
	if current_item_indexs.is_empty():
		add_to_new_grid(current_item_indexs,item_data,item_num)
	else:
		for index in current_item_indexs:
			var num:int = backpack_grids.get(index)
			if num < stack_limit:
				var empty_space:int = stack_limit - num
				
				#如果要放置的数量大于剩余空间
				var current_num:int = 0
				if item_num > empty_space:
					current_num = stack_limit
					backpack_grids.set(index,current_num)
				else:
					current_num = num + item_num
					backpack_grids.set(index,current_num)
				update_number.emit(index,current_num)
				
				
				#将要放置的数量减去剩余空间,得到剩下需要放置的数量
				item_num = max(0,item_num - empty_space)
			#当放置的数量为0时，退出循环
			if item_num == 0:
				break
			
		# 如果添加到现有的格子中之后还有剩余，尝试添加到新的格子
		if item_num > 0:
			add_to_new_grid(current_item_indexs,item_data,item_num)
	backpack.set(item_name,current_item_indexs)		
	print("backpack:",backpack)
	print("backpack_grids:",backpack_grids)
	
# 获得可叠加的物品
func add_stackable_item(item_data:Dictionary,item_num:int) -> void:
	if stack_limit != single_grid_limit:
		stack_limit = single_grid_limit
	add_items(item_data,item_num)

# 获得不可叠加的物品
func add_unstackable_item(item_data:Dictionary,item_num:int) -> void:
	if stack_limit != 1:
		stack_limit = 1
	add_items(item_data,item_num)


# 拾取物品
func pick_up_item(item_data:Dictionary,item_num:int):
	#判断是否为独占一格的装备
	var item_name:String = item_data.name
	if EquipmentData.database.has(item_data):
		if not item_data.is_stackable:
			add_unstackable_item(item_data,item_num)
		else:
			add_stackable_item(item_data,item_num)	
		
	else:			
		add_stackable_item(item_data,item_num)
	

# 使用物品
func use_item(item_name:String) -> void:
	var current_item_indexs:Array = backpack.get(item_name,[])
	for index in current_item_indexs:
		var num:int = backpack_grids.get(index)
		num -= 1
		backpack_grids.set(index,num)
		update_number.emit(index,num)
		#当物品数量消耗为0，去除对应索引
		if num == 0:
			empty_grid_index = index
			current_item_indexs.erase(index)
		break
	print("backpack:",backpack)
	print("backpack_grids:",backpack_grids)
	
# 获取玩家身上物品的数量 
func get_item_count(item_name:String) -> int:
	var total_num:int = 0
	var current_item_indexs:Array = backpack.get(item_name,[])
	for index in current_item_indexs:
		total_num += backpack_grids[index]
	return total_num

# 清空玩家身上的资源
func take_all_resource(resource_name:String) -> int:
	var total_resource_count:int = get_item_count(resource_name)
	var current_resource_indexs:Array = backpack.get(resource_name,[])
	for index in current_resource_indexs:
		backpack_grids[index] = 0
		update_number.emit(index,0)
	current_resource_indexs.clear()
	empty_grid_index = get_empty_grid_index()
	return total_resource_count



func _init() -> void:

	backpack_grids.resize(backpack_limit)
	backpack_grids.fill(0)
