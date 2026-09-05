extends CharacterBody3D

@export var hp:float = 100

@export var attack_power:float = 20

@export var speed:float = 5

@export var turn_around_speed:float = 0.15

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

enum MoveMode {
	WANDER = 0,
	CHASE = 1
}
# 移动模式
var current_move_mode: MoveMode = MoveMode.WANDER

#漫步计时器
@onready var wander_timer: Timer = $WanderTimer

# 漫步范围
@export var wander_radius: float = 10.0

# 是否开始漫步
var is_start_wander:bool = false

# 是否等待中
var is_waiting: bool = false

# 跟随目标
var follow_target:Node3D

# 攻击目标
var attack_target:Node3D 

# 玩家是否在攻击范围内
var is_player_in_range:bool = false

enum AttackSide {
	RIGHT = 0,
	LEFT = 1
}
# 攻击方向
var current_attack_side: AttackSide = AttackSide.LEFT



# 移动
func move() -> void:
	#print("当前移动模式：","漫步" if current_move_mode == MoveMode.WANDER else "追踪")
	if current_move_mode == MoveMode.WANDER:
		# 到达目的地并在等待状态时，归零速度并阻断后续移动
		if is_waiting:
			return
		
		if not is_start_wander:
			pick_random_target()
			is_start_wander = true
			
	elif current_move_mode == MoveMode.CHASE:
		if follow_target:
			#设置目标位置
			nav_agent.set_target_position(follow_target.global_position)
		else:
			current_move_mode = MoveMode.WANDER
			is_start_wander = false
			return
	
	# 3. 如果已经到达目的地（即使没有触发 signal），避免原地滑动
	if nav_agent.is_navigation_finished():
		return
	
	var next_path_pos: Vector3 = nav_agent.get_next_path_position()
	var move_dir: Vector3 = global_position.direction_to(next_path_pos)
	
	# 设置移动速度
	velocity = move_dir * speed
	
	# --- 转向逻辑（平滑版）---
	# 1. 计算水平方向向量，消除 Y 轴影响（避免敌人上下倾斜）
	move_dir.y = 0

	# 2. 只有当移动距离足够大时才旋转，防止到达终点时因重合产生抖动/报错
	if move_dir.length_squared() > 0.001:
		move_dir = move_dir.normalized()
		
		# 3. 根据移动方向创建目标旋转矩阵（Basis）
		var target_basis := Transform3D.IDENTITY.looking_at(move_dir, Vector3.UP).basis
		
		# 4. 使用 slerp 平滑插值旋转
		# 0.15 为旋转平滑度（范围 0 到 1），数值越大转得越快，数值越小转得越慢
		basis = basis.slerp(target_basis, turn_around_speed)
	
	move_and_slide()

# 获取导航网格上的随机可达点
func pick_random_target() -> void:
	var map := get_world_3d().navigation_map
	
	# 1. 在以当前位置为中心、wander_radius 为半径的球体内生成一个随机偏移向量
	var random_dir := Vector3(
		randf_range(-1.0, 1.0),
		0, # 保持水平面
		randf_range(-1.0, 1.0)
	).normalized()
	
	var target_pos := global_position + random_dir * randf_range(0, wander_radius)
	print("target_pos:",target_pos)
	# 2. 将这个随机坐标贴合/投影到 NavMesh 上，确保是可达的合法位置
	var random_point := NavigationServer3D.map_get_closest_point(map, target_pos)
	print("目标位置:",random_point)
	
	if random_point.is_zero_approx() and not global_position.is_zero_approx():
		await get_tree().physics_frame
		pick_random_target()
		return
	
	nav_agent.set_target_position(random_point)
	is_waiting = false
	
	
	
# 攻击
func attack() -> void:
	if is_player_in_range and not $AnimationPlayer.is_playing():
		#计算玩家距离熊的左爪和右爪之间的距离
		var distance_to_left:float = ($Body/Paws/LeftPaw.global_position - attack_target.global_position).length()
		var distance_to_right:float = ($Body/Paws/RightPaw.global_position - attack_target.global_position).length()
		if distance_to_left <= distance_to_right:
			current_attack_side = AttackSide.LEFT
		else:
			current_attack_side = AttackSide.RIGHT
		
		if current_attack_side:
			$AnimationPlayer.play("left_paw_attack")
		else:
			$AnimationPlayer.play("right_paw_attack")

# 受到攻击
func get_hit(damage:float) -> void:
	hp -= damage
	print("敌人当前血量：",hp)
	if hp <= 0:
		print("敌人已死亡")
		queue_free()


			
func _physics_process(delta: float) -> void:
	#进行移动
	move()

func _process(delta: float) -> void:
	attack()


# 当到达当前随机点时触发
func _on_target_reached() -> void:
	print("到达指定地点")
	if not is_waiting and current_move_mode == MoveMode.WANDER:
		is_waiting = true
		velocity = Vector3.ZERO
		# 到达后随机等待 1 到 4 秒再走向下一个点
		wander_timer.start(randf_range(1.0, 4.0))

# 定时器结束，前往下一个点
func _on_wander_timer_timeout() -> void:
	print("定时器结束，前往下一个位置")
	if current_move_mode == MoveMode.WANDER:
		pick_random_target()


func _on_attack_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		is_player_in_range = true
		#将攻击目标转为玩家
		attack_target = body
		


func _on_attack_area_3d_body_exited(body: Node3D) -> void:
	if body is Player:
		is_player_in_range = false
		#将攻击目标转为玩家
		attack_target = null


func _on_hit_box_area_entered(area: Area3D) -> void:
	if area is DamageArea:
		get_hit(area.owner.attack_power)


func _on_chase_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		current_move_mode = MoveMode.CHASE
		follow_target = body
		is_start_wander = false
	


func _on_chase_area_3d_body_exited(body: Node3D) -> void:
	if body is Player:
		current_move_mode = MoveMode.WANDER
		follow_target = null
