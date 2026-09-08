# 玩家
class_name Player
extends CharacterBody3D

@export_group("玩家生命值")
@export var hp:float = 100.0

@export_group("玩家移动速度")
@export var speed:float = 5.0
@export var speed_up_acceleration_rate:float = 2
# 加速倍率变化的速度
@export	var accel_speed:float = 2.0 
var current_acceleration_rate:float = 1

@export_category("玩家背包")
@export var backpack:Dictionary[String, int] = {}

@export_category("玩家持有装备")
@export var holding_euipment:Node3D
#当前使用装备类型
var current_equipment_type:int = EquipmentData.EquipmentType.TREE_CUTTING

#装备栏
var equipment_bar:Dictionary = {}

#装备挂载的节点
@onready var equipment_holder:Node3D = $EuipmentHolder

# 移动玩家朝向
func move_angle() -> void:
	var target_pos: Vector3 = get_mouse_3d_position()
	if target_pos != Vector3.ZERO and global_position.distance_to(target_pos) > 0.1:
		look_at(target_pos, Vector3.UP)

# 封装好的 2D 鼠标转 3D 地面坐标函数
func get_mouse_3d_position() -> Vector3:
	var camera: Camera3D = get_viewport().get_camera_3d()
	if not camera: 
		return Vector3.ZERO
	
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var ray_origin: Vector3 = camera.project_ray_origin(mouse_pos)
	var ray_dir: Vector3 = camera.project_ray_normal(mouse_pos)
	
	# 一行计算射线与平面 (Y = global_position.y) 的交点
	if ray_dir.y == 0: 
		return Vector3.ZERO
	var t: float = (global_position.y - ray_origin.y) / ray_dir.y
	return ray_origin + ray_dir * t
	

# 移动
func move() -> void:
	# 获取输入方向和处理移动/减速
	var input_dir := Input.get_vector("left","right","forward","backward")
	var direction := (transform.basis * Vector3(input_dir.x,0,input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed * current_acceleration_rate
		velocity.z = direction.z * speed * current_acceleration_rate
	else:
		velocity.x = move_toward(velocity.x,0,speed)
		velocity.z = move_toward(velocity.z,0,speed)
		
	move_and_slide()

# 玩家加速
func speed_up(delta:float) -> void:
	# 确定目标倍率：按住按键时为冲刺倍率，否则恢复为 1.0
	var target_rate:float = speed_up_acceleration_rate if Input.is_action_pressed("speed_up") else 1.0

	# 让倍率平滑向目标值移动
	current_acceleration_rate = move_toward(current_acceleration_rate, target_rate, accel_speed * delta)

## 加载并装备指定 ID 的装备
func load_equipment(equipment_id: String) -> void:
	# 1. 查数据
	if not EquipmentData.database.has(equipment_id):
		push_error("装备不存在: " + equipment_id)
		return
	
	var data: Dictionary = EquipmentData.database[equipment_id]
	var equip_type: int = data.type
	
	# 2. 卸载同类型旧装备
	unload_equipment(equip_type)
	
	# 3. 实例化装备场景
	var scene: PackedScene = load(data.scene_path)
	if scene == null:
		push_error("装备场景加载失败: " + data.scene_path)
		return
	
	var instance: Node = scene.instantiate()
	
	# 5. 记录并初始化
	equipment_bar[equip_type] = instance
	#instance.set_equipment_data(data)  # 如果装备脚本有这个方法
	
	print("已装备: ", data.name)
	#_apply_stats(data.stats, true)

## 卸载指定类型的装备
func unload_equipment(equip_type: int) -> void:
	if equipment_bar.has(equip_type):
		var old = equipment_bar[equip_type]
		#var old_data = old.get_equipment_data()  # 假设装备脚本提供数据
		
		#_apply_stats(old_data.stats, false)  # 移除属性加成
		old.queue_free()
		equipment_bar.erase(equip_type)
		#print("已卸下: ", old_data.name)

# 将装备装上
# 将装备装上，返回被替换下来的旧装备（不销毁实例）
func put_on_equipment(equipment: Node) -> Node:
	var old_equipment: Node = null
	
	# 如果当前已有装备，先移出（不销毁）
	if equipment_holder.get_child_count() > 0:
		old_equipment = equipment_holder.get_child(0)
		equipment_holder.remove_child(old_equipment)
	
	# 装入新装备
	equipment_holder.add_child(equipment)
	holding_euipment = equipment
	
	return old_equipment

# 切换装备
func switch_equipment() -> void:
	var type_num:int = EquipmentData.EquipmentType.size()
	current_equipment_type = (current_equipment_type + 1) % type_num
	put_on_equipment(equipment_bar.get(current_equipment_type))

# 使用装备
func use_euipment() -> void:
	if holding_euipment:
		if current_equipment_type == EquipmentData.EquipmentType.TREE_CUTTING \
		or current_equipment_type == EquipmentData.EquipmentType.HUNTING:
			attack()
		elif current_equipment_type == EquipmentData.EquipmentType.COUSUMABLE:
			use_item()
# 攻击
func attack() -> void:
	if Input.is_action_pressed("use_equipment"):
		holding_euipment.attack()
	
# 使用道具
func use_item() -> void:
	if Input.is_action_just_pressed("use_equipment"):
		holding_euipment.use_item()

# 收集资源
func collect_resource(resource_name:String) -> void:
	var current_num:int = backpack.get_or_add(resource_name,0)
	backpack[resource_name] = current_num + 1
	print("玩家当前资源:",backpack)

# 获取玩家身上资源的数量 
func get_resource_count(resource_name:String) -> int:
	return backpack.get(resource_name,0)

# 清空玩家身上的资源
func take_all_resource(resource_name:String) -> int:
	var total_resource_count:int = get_resource_count(resource_name)
	backpack.set(resource_name,0)
	return total_resource_count

# 受到攻击
func get_hit(damage:float) -> void:
	hp -= damage
	print("玩家当前血量：",hp)
	if hp <= 0:
		print("玩家已死亡")
		pass


func _physics_process(delta: float) -> void:
	
	#处理玩家移动
	move()	
		
func _ready() -> void:
	load_equipment("axe")
	put_on_equipment(equipment_bar.get(EquipmentData.EquipmentType.TREE_CUTTING))	
	
	load_equipment("bomb")
	
func _process(delta: float) -> void:
	move_angle()
		
	use_euipment()
	
	speed_up(delta)

func _unhandled_input(event: InputEvent) -> void:
	
	# 切换装备
	if event.is_action_pressed("switch_equipment"):
		print("切换装备")
		switch_equipment()
	

func _on_hit_box_area_entered(area: Area3D) -> void:
	if area is DamageArea:
		get_hit(area.owner.attack_power)
