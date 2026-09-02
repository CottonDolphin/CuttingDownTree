# 仓库（收集并统计已收集的木材）
extends Node3D


# 记录当前是否有玩家处于交互范围内
var is_player_in_range: bool = false
var current_player: Player = null


func deposit_wood() -> void:
	if current_player == null:
		return
	
	# 检查玩家身上是否有木头
	if current_player.has_method("get_resource_count") and current_player.get_resource_count("wood") > 0:
		var wood_amount = current_player.take_all_resource("wood")
		
		# 提交到全局单例或得分系统
		GameManager.update_collected_amount(wood_amount)
		print("成功提交了 ", wood_amount, " 个木头！")
	else:
		print("身上没有木头可以提交！")

func _unhandled_input(event: InputEvent) -> void:
	# 当玩家在范围内，并且按下了“交互”按键（如 E 键）
	if is_player_in_range and event.is_action_pressed("interact"):
		print("玩家按E了")
		deposit_wood()


func _on_body_entered(body: Node3D) -> void:
	# 假设玩家节点属于 "player" 组，或者判断是 Player 类
	if body is Player:
		is_player_in_range = true
		current_player = body
		# 这里可以显示提示 UI，比如：$InteractPrompt.show()

func _on_body_exited(body: Node3D) -> void:
	if body == current_player:
		is_player_in_range = false
		current_player = null
		# 这里可以隐藏提示 UI，比如：$InteractPrompt.hide()
