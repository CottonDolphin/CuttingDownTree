# 玩家
class_name Player
extends CharacterBody3D

@export_group("玩家移动速度")
@export var speed:float = 5.0
@export var speed_up_acceleration_rate:float = 2
# 加速倍率变化的速度
@export	var accel_speed:float = 2.0 
var current_acceleration_rate:float = 1

@export_category("玩家持有武器")
@export var holding_weapon:Node3D

@export_category("玩家背包")
@export var backpack:Dictionary[String, int] = {}


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

# 攻击
func attack() -> void:
	
	if Input.is_action_pressed("attack"):
		
		# 通过变量 holding_weapon 获取它下面的 AnimationPlayer
		var anim_player := holding_weapon.get_node("AnimationPlayer") as AnimationPlayer
		if anim_player:
			if not anim_player.is_playing():
				#print("触发攻击动作！")
				anim_player.play("attack")
		else:
			push_warning("holding_weapon 下找不到 AnimationPlayer")

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


func _physics_process(delta: float) -> void:
	
	#处理玩家移动
	move()	
		
func _ready() -> void:
	pass
		
	
func _process(delta: float) -> void:
	move_angle()
	
	attack()
	
	speed_up(delta)
