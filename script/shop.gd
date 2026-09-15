# 商店界面
extends Control

#主要内容
@onready var main_contain:HBoxContainer = $MarginContainer/VBoxContainer/MarginContainer2/MainContain

# 玩家
@export var player:Player

# 玩家背包数据管理
var backpack_data_manager:BackpackDataManager

# 背包UI
var backpack_ui:BackPackUI


func _ready() -> void:
	# 检查当前是否在 Godot 编辑器中预览
	if not Engine.is_editor_hint():
		# 如果是实际运行游戏，则自动删掉编辑器里手动放的占位子节点
		for child in main_contain.get_children():
			if child is BackPackUI:
				child.queue_free()
			
	if player:
		backpack_data_manager = player.backpack_data_manager
		player.backpack_ui.reparent(main_contain)
		
