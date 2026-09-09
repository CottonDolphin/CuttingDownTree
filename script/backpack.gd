# 背包窗口
class_name BackPack
extends Control

@export_category("玩家背包")
@export var backpack:Dictionary[String,Array] = {}

var backpack_grids:Array = []

# 空白格子序号
var empty_grid_index:int = 0

# 背包上限
@export var backpack_limit:int = 8

# 单格资源上限
@export var resource_limit:int = 5

# 添加到新格子中
func add_to_new_grid(index_array:Array) -> void:
	if empty_grid_index > -1 and empty_grid_index < backpack_limit:
		backpack_grids[empty_grid_index] += 1
		index_array.append(empty_grid_index)
		if backpack_grids[empty_grid_index] == 1:
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

# 收集资源
func collect_resource(resource_name:String) -> void:
	print("empty_grid_index:",empty_grid_index)
	var current_resource_indexs:Array = backpack.get(resource_name,[])
	
	# 如果背包中没有该资源，尝试添加到新的格子
	if current_resource_indexs.is_empty():
		add_to_new_grid(current_resource_indexs)
	else:
		var is_add:bool = false
		for index in current_resource_indexs:
			var num:int = backpack_grids.get(index)
			if num < resource_limit:
				num += 1
				backpack_grids.set(index,num)
				is_add = true
		# 如果没有添加到现有的格子中，尝试添加到新的格子
		if not is_add:
			add_to_new_grid(current_resource_indexs)
	backpack.set(resource_name,current_resource_indexs)		
	print("backpack:",backpack)
	print("backpack_grids:",backpack_grids)
	

# 获取玩家身上资源的数量 
func get_resource_count(resource_name:String) -> int:
	var total_num:int = 0
	var current_resource_indexs:Array = backpack.get(resource_name,[])
	for index in current_resource_indexs:
		total_num += backpack_grids[index]
	return total_num

# 清空玩家身上的资源
func take_all_resource(resource_name:String) -> int:
	var total_resource_count:int = get_resource_count(resource_name)
	var current_resource_indexs:Array = backpack.get(resource_name,[])
	for index in current_resource_indexs:
		backpack_grids[index] = 0
	current_resource_indexs.clear()
	empty_grid_index = get_empty_grid_index()
	return total_resource_count

func _ready() -> void:
	backpack_grids.resize(backpack_limit)
	backpack_grids.fill(0)
