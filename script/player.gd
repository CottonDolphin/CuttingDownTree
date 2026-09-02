# 玩家
class_name Player
extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var holding_weapon:Node3D


@export var backpack:Dictionary[String, int] = {}


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
	

# 攻击
func attack() -> void:
	
	if Input.is_action_just_pressed("attack"):
		print("触发攻击动作！")
		# 通过变量 holding_weapon 获取它下面的 AnimationPlayer
		var anim_player := holding_weapon.get_node("AnimationPlayer") as AnimationPlayer
		if anim_player:
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
	# 添加重力
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 处理跳跃
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# 获取输入方向和处理移动/减速
	var input_dir := Input.get_vector("left","right","forward","backward")
	var direction := (transform.basis * Vector3(input_dir.x,0,input_dir.y)).normalized()
	
	
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x,0,SPEED)
		velocity.z = move_toward(velocity.z,0,SPEED)
		
	move_and_slide()
		
		
func _ready() -> void:
	# 假设武器被装备到了 WeaponHolder 下
	if has_node("WeaponHolder/AxeBase"):
		var weapon = $WeaponHolder/AxeBase
		
	
func _process(delta: float) -> void:
	move_angle()
	
	attack()
