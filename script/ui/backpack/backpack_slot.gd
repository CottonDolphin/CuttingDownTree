class_name BackpackSlot
extends Button

# 格子索引
var slot_index:int 

# 格子是否被填充
var is_filled:bool

# 格子的数据
var slot_data:Dictionary

# 格子图标
@onready var icon_slot:TextureRect = $TextureRect

func fill_slot(data:Dictionary):
	slot_data = data
	is_filled = true
	icon_slot.texture = load(data.icon)
	
