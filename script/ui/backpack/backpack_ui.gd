# 背包窗口
class_name BackPackUI
extends Control

# 背包的格子数
@export var grid_num:int = 8

@onready var grid_container:GridContainer = $MarginContainer/GridContainer

var backpack_slot_prefab:PackedScene = preload("res://scene/ui/backpack/backpack_slot.tscn")

var backpack_slots:Array[BackpackSlot] = []



# 填充新的空格
func _on_fill_new_slot(slot_index: int, item_data: Dictionary,increase_num:int) -> void:
	# 获取对应索引的空格
	var slot:BackpackSlot = backpack_slots.get(slot_index)
	slot.fill_slot(item_data)
	
	# 更新显示数字
	slot.update_number(increase_num)

# 更新显示数字
func _on_update_number(slot_index: int,current_num:int) -> void:
	var slot:BackpackSlot = backpack_slots.get(slot_index)
	if current_num <= 0:
		slot.clear_slot()
	else:
		slot.update_number(current_num)

# 生成背包的格子
func generate_slots() -> void:
	for i in grid_num:
		var slot:BackpackSlot = backpack_slot_prefab.instantiate()
		grid_container.add_child(slot)
		slot.slot_index = i
		backpack_slots.append(slot)




func _ready() -> void:
	
	generate_slots()
