# 商店界面
class_name Shop
extends Control

#主要内容
@onready var main_contain:Container = $MarginContainer/VBoxContainer/MarginContainer2/MainContain

#背包容器
@onready var backpack_container:Container = $MarginContainer/VBoxContainer/MarginContainer2/MainContain/VBoxContainer/BackpackContainer


# 玩家
@export var player:Player

# 玩家背包数据管理
var backpack_data_manager:BackpackDataManager

# 背包UI
var backpack_ui:BackPackUI

# 所有商品格子
@onready var all_products_container:Container = $MarginContainer/VBoxContainer/MarginContainer2/MainContain/AllProducts

# 继续游戏
signal continue_game()

# 打开商店
func open_shop() -> void:
	self.visible = true
	
	if backpack_ui:
		backpack_ui.reparent(backpack_container)
		backpack_ui.visible = true
	
	# 暂停游戏
	GameManager.pause()
	
	# 更新金币数量
	UiUpdate.update_gold(GameManager.get_item_num("gold"))

# 关闭商店
func close_shop() -> void:
	self.visible = false
	
	if backpack_ui and player:
		backpack_ui.reparent(player.backpack_container)
		backpack_ui.visible = false
	
	# 恢复游戏
	GameManager.resume()

func _ready() -> void:
	#清空预览用的背包UI
	var backpack:Node = backpack_container.get_child(0)
	backpack.queue_free()	
	
	var product_slots:Array[ProductSlot] = all_products_container.product_slots
	for slot in product_slots:
		slot.purchase_item.connect(_purchase_item)
			
	if player:
		backpack_data_manager = player.backpack_data_manager
		backpack_ui = player.backpack_ui
	
	#商店窗口初始隐藏
	self.visible = false
	
func _purchase_item(data:Dictionary) -> void:

	var item_name:String = data.name
	print("购买",item_name)
	if data.price <= GameManager.get_item_num("gold"):
		GameManager.spend_gold(data.price)
		player.add_to_backpack(EquipmentData.database.get(data.name),1)
	else:
		print("你没有足够的金币")

func _on_continue_game_pressed() -> void:
	close_shop()
	
	continue_game.emit()
