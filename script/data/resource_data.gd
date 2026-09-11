# resource_data.gd（AutoLoad / 全局数据）
extends Node


# 装备数据库（实际项目中可从 JSON 文件加载）
var database: Dictionary = {
	"wood": {
		"name": "wood",
		"scene_path": "res://scene/resource/wood.tscn",
		"is_stackable":true,
		"icon":"res://assets/icon/resource/wood.png",
	},
}
