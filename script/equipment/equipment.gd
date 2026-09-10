class_name Equipment
extends Node3D

var is_holided:bool = false


func set_equipment_data(data: Dictionary) -> void:
	self.name = data.name
