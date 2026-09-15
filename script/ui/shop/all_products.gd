extends MarginContainer


# 商品的格子数
@export var grid_num:int = 6

@onready var grid_container:GridContainer = $MarginContainer/GridContainer

var product_slot_prefab:PackedScene = preload("res://scene/ui/shop/product_slot.tscn")

var product_slots:Array[ProductSlot] = []

var start_index:int = 0

# 生成商品的格子
func generate_slots() -> void:
	for i in grid_num:
		var slot:ProductSlot = product_slot_prefab.instantiate()
		grid_container.add_child(slot)
		slot.slot_index = i
		product_slots.append(slot)

# 更新商品信息
func update_product_data() -> void:
	for i in grid_num:
		var index:int = i + start_index
		
		#获取要更新信息的格子
		var slot:ProductSlot = product_slots.get(i)
		
		var data:Dictionary
		if index > -1 and index < ProductData.database.size():
			data = ProductData.database.get(index)
		else:
			data = ProductData.database.get(ProductData.database.size() - 1)
		
		if slot:
			slot.load_data(data)
 

func _ready() -> void:
	# 检查当前是否在 Godot 编辑器中预览
	if not Engine.is_editor_hint():
		# 如果是实际运行游戏，则自动删掉编辑器里手动放的占位子节点
		for child in grid_container.get_children():
			child.queue_free()

	generate_slots()
	update_product_data()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
