class_name ProductSlot
extends Button


# 格子索引
var slot_index:int 

# 格子的数据
var slot_data:Dictionary

# 商品图标
@onready var product_icon:TextureRect = $MarginContainer/VBoxContainer/ProductIcon

# 商品名称
@onready var product_name:Label = $MarginContainer/VBoxContainer/ProductName

# 商品价格
@onready var product_price:Label = $MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/MarginContainer/ProductPrice

# 锁定遮罩
@onready var lock_cover:Container = $LockCover

# 购买物品
signal purchase_item(slot_data:Dictionary)


# 设置商品的锁定状态
func set_lock_status(is_unlocked:bool):
	lock_cover.visible = !is_unlocked
	self.disabled = !is_unlocked

# 加载存储数据
func load_data(data:Dictionary) -> void:
	slot_data = data
	product_icon.texture = load(data.icon)
	product_name.text = data.name
	product_price.text = str(data.price)
	set_lock_status(data.is_unlocked)


func _on_pressed() -> void:
	purchase_item.emit(slot_data)
