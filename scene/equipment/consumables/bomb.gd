class_name Bomb
extends Consumable

# 碰撞体积
@onready var collision:CollisionShape3D = $CollisionShape3D

# 生成炸弹
func generate_bomb() -> Bomb:
	# 1. 查数据
	var equipment_id:String = "bomb"
	if not EquipmentData.database.has(equipment_id):
		push_error("装备不存在: " + equipment_id)
		return
	var data: Dictionary = EquipmentData.database[equipment_id]
	
	var scene: PackedScene = load(data.scene_path)
	var instance: Node = null
	if scene == null:
		push_error("装备场景加载失败: " + data.scene_path)
		return null
	
	instance = scene.instantiate()
	return instance

# 放置炸弹
func place_bomb(player:Player,bomb:Bomb) -> void:
	get_tree().current_scene.add_child(bomb)
	
	var distance := 1.0
	bomb.global_position = player.global_position + -player.global_transform.basis.z * distance
	bomb.global_position.y = player.global_position.y
	
	# 开启碰撞体积
	bomb.collision.disabled = false
	
# 使用道具
func use_item(player:Player) -> void:
	print("使用炸弹")
	
	#生成炸弹实例
	var bomb:Bomb = generate_bomb()
	
	#放置在玩家当前位置前方
	place_bomb(player,bomb)
	
