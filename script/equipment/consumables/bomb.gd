class_name Bomb
extends Consumable

# 碰撞体积
@onready var collision:CollisionShape3D = $CollisionShape3D

# 定时器
@onready var timer:Timer = $Timer

# 外观
@onready var visuals:MeshInstance3D = $Visuals/MeshInstance3D

# 表面材质
var material: StandardMaterial3D

# 初始颜色
var origin_color:Color

# 警告时间
@export var warning_time:float = 3

# 固定间隔
const INTERVAL:float = 0.1

# 闪烁间隔
var twinkle_interval:float = INTERVAL

# 上次闪烁时间
var last_twinkle_time:float = 0 

@export var attack_power:float = 100

# 伤害区域
@onready var damage_area:Area3D = $DamageArea

# 伤害区域碰撞体
@onready var damage_area_collision:CollisionShape3D = $DamageArea/CollisionShape3D

# 爆炸最大半径（建议和你的 CollisionShape 匹配）
@export var explosion_radius: float = 5.0
# 基础击退力度
@export var knockback_force: float = 20.0

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
	
	#启动炸弹
	bomb.timer.start()
	
# 造成伤害
func cause_damage() -> void:
	damage_area_collision.disabled = false
	
# 击退
func knockback() -> void:
	# 获取当前重叠的所有物理体（如 CharacterBody3D 或 RigidBody3D）
	# 如果你的受击判定是 Area3D，请改为 damage_area.get_overlapping_areas()
	var targets = damage_area.get_overlapping_bodies()
	
	for target in targets:
		# 忽略炸弹自身
		if target == self:
			continue
			
		# 计算从炸弹指向目标的向量
		var direction: Vector3 = target.global_position - global_position
		var distance: float = direction.length()
		
		# 超出最大半径则不处理
		if distance > explosion_radius:
			continue
			
		# 归一化方向向量（如果距离极近避免除以0）
		if distance > 0.001:
			direction = direction.normalized()
		else:
			direction = Vector3.UP # 极近时默认向上弹开
			
		# 计算距离衰减系数（距离越近值越接近 1.0，最远边缘接近 0.0）
		# 使用 clampf 确保比例在 0.0 ~ 1.0 之间
		var impulse_factor: float = 1.0 - clampf(distance / explosion_radius, 0.0, 1.0)
		
		# 计算最终的击退向量（可适当增加一个向上弹起的 y 轴力量，体验更好）
		direction.y += 0.1 # 让单位被稍微炸飞到空中
		direction = direction.normalized()
		
		var final_knockback: Vector3 = direction * knockback_force * impulse_factor
		
		# 尝试将击退应用到目标上
		if target.has_method("apply_knockback"):
			target.apply_knockback(final_knockback)
		elif target is RigidBody3D:
			# 如果目标是刚体，直接施加冲量
			target.apply_central_impulse(final_knockback)

# 爆炸
func explode() -> void:
	cause_damage()

	# 开启一个小计时器或等待 0.1 秒，保证碰撞区域生效完再清理
	await get_tree().create_timer(0.1).timeout
	
	knockback()
	
	queue_free()

# 开始警告
func begin_warning() -> void:
	var time_left:float = timer.get_time_left()
	
	# 当剩余时间小于指定值时,炸弹开始闪烁
	if time_left < warning_time:
		var current_time:float = Time.get_unix_time_from_system()
		if current_time - last_twinkle_time > twinkle_interval:
			twinkle()
			last_twinkle_time = current_time
			twinkle_interval = INTERVAL * time_left

# 闪烁
func twinkle() -> void:
	var current_color:Color = material.albedo_color

	if current_color == origin_color:
		current_color = Color.RED
	else:
		current_color = origin_color
		
	material.albedo_color = current_color
	
func _ready() -> void:
	material = visuals.mesh.surface_get_material(0)
	origin_color = material.albedo_color

func _process(delta: float) -> void:
	
	if not timer.is_stopped():
		begin_warning()
