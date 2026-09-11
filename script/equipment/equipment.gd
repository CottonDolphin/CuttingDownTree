class_name Equipment
extends Node3D

# 基础属性
var type:int


var is_holided:bool = false



func set_equipment_data(data: Dictionary) -> void:
	self.name = data.name
	self.type = data.type
