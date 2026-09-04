extends CharacterBody3D

@export var hp:float = 100

@export var attack_power:float = 20

@export var speed:float = 5




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


# 跟随
func follow() -> void:
	if follow_target == null:
		follow_target = get_tree().get_first_node_in_group("Player")
	
	if follow_target:
		$NavigationAgent3D.set_target_position(follow_target.global_position)
		
		velocity = global_position.direction_to($NavigationAgent3D.get_next_path_position()) * speed
		
		move_and_slide()
	
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
	follow()

func _process(delta: float) -> void:
	attack()


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
