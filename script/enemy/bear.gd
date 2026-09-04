extends CharacterBody3D


@export var attack_power:float = 20

@export var hp:float = 100

const SPEED = 5.0
const JUMP_VELOCITY = 4.5


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
	pass
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#if direction:
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
#
	#move_and_slide()

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
