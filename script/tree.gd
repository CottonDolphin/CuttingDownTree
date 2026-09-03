# 树
class_name MyTree
extends Node3D

@export var hp:float = 50

@export var wood_scene: PackedScene

@export var resource_num:int = 5

# 树被武器攻击时触发的方法
func get_hit(damage:float) -> void:
	hp -= damage
	print("树的剩余血量为:",hp)
	
	if hp <= 0:
		# 1. 先记录位置（删除前保存，否则删了就取不到了）
		var drop_position := global_position
		
		# 2. 【关键】立刻隐藏树，并禁用所有碰撞
		visible = false
		for col in find_children("*", "CollisionShape3D"):
			col.disabled = true
		
		# 3. 生成木材（此时玩家看不到树，也不会物理碰撞）
		for i in resource_num:
			var offset := Vector3(
				randf_range(-1.5, 1.5),
				0.5,  # 稍微抬高一点，避免卡进地面
				randf_range(-1.5, 1.5)
			)
			spawn_wood(drop_position + offset)
		
		# 4. 安全删除
		queue_free()

# 生成木材
func spawn_wood(pos: Vector3) -> void:
	if not wood_scene:
		push_error("wood_scene 未赋值！")
		return
	var wood = wood_scene.instantiate()
	get_tree().current_scene.add_child(wood)
	wood.global_position = pos
	# 给一点随机初始速度和旋转，让掉落更自然
	if wood is RigidBody3D:
		wood.linear_velocity = Vector3(
			randf_range(-1, 1),
			randf_range(2, 4),   # 向上抛一点
			randf_range(-1, 1)
		)
		wood.angular_velocity = Vector3(
			randf_range(-2, 2),
			randf_range(-2, 2),
			randf_range(-2, 2)
		)
	


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function bs

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_hit_box_area_entered(area: Area3D) -> void:
	if area is DamageArea:
		get_hit(area.owner.attack_power)
