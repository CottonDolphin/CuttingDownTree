class_name BackpackSlot
extends Button

# 格子索引
var slot_index:int 

# 格子是否被填充
var is_filled:bool

# 格子的数据
var slot_data:Dictionary

# 格子图标
@onready var icon_slot:TextureRect = $MarginContainer/TextureRect

# 格子数字标签
@onready var number_label:Label = $MarginContainer/Label

# 填充格子信息
func fill_slot(data:Dictionary) -> void:
	slot_data = data
	is_filled = true
	icon_slot.texture = load(data.icon)

# 修改显示数字
func update_number(number:int) -> void:
	if number <= 0:
		push_error("给定数字不合法") 
	
	if number == 1:
		number_label.text = ""
	else:
		number_label.text = str(number)
