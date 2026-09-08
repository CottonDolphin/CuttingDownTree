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
		"name": "斧头",
		"type": EquipmentType.TREE_CUTTING,
		"scene_path": "res://scene/equipment/tree cutting tools/axe.tscn",
		"stats": {"attack": 10, "speed": -2}
	}
}
