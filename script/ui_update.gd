# 负责UI的更新
extends Node

# 更新木头数量
signal wood_updated(collected_amount: int,target_amount:int)

# 更新木头的数量
func update_wood(collected_amount:int,target_amount:int) -> void:
	wood_updated.emit(collected_amount,target_amount)
