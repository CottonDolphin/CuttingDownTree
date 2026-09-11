# equipment_data.gd（AutoLoad / 全局数据）
extends Node

# 装备类型
enum EquipmentType {
	TREE_CUTTING = 0,
	HUNTING = 1,
	COUSUMABLE = 2
}

# 装备数据库（实际项目中可从 JSON 文件加载）
var database: Dictionary = {
	"axe": {
		"name": "axe",
		"type": EquipmentType.TREE_CUTTING,
		"scene_path": "res://scene/equipment/tree cutting tools/axe.tscn",
		"is_stackable":false,
		"icon":"res://assets/icon/equipment/tree cutting tool/axe.png",
		"stats": {"attack": 10, "speed": -2}
	},
	"bomb": {
		"name": "bomb",
		"type": EquipmentType.COUSUMABLE,
		"scene_path": "res://scene/equipment/consumables/bomb.tscn",
		"icon":"res://assets/icon/equipment/consumables/bomb.png",
		"is_stackable":true,
		"stats": {"attack": 10, "speed": -2}
	}
}
