# product_data.gd（AutoLoad / 全局数据）
extends Node


# 商品数据库（实际项目中可从 JSON 文件加载）
var database: Array[Dictionary] = [
	{
		"name": "bomb",
		"icon":"res://assets/icon/equipment/consumables/bomb.png",
		"price":5,
		"is_unlocked":true
	},
	{
		"name": "unknown",
		"icon":"res://assets/icon/equipment/consumables/bomb.png",
		"price":5,
		"is_unlocked":false
	}
]
